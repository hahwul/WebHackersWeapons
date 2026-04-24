# Validate every weapon TOML file against the canonical schema.
#
# Run from web/ (so the toml shard resolves):
#   crystal run scripts/validate.cr
#
# Exits 0 when all files pass, 1 on any error. Warnings do not fail the run.
#
# Checks (errors):
#   - TOML parses
#   - `name`   is a non-empty string
#   - `url`    is a non-empty array of strings; each starts with http:// or https://
#   - `source` (optional) is a string starting with http:// or https://
#   - at least one of `url` or `source` is present
#   - `category` ∈ {tool, tool-addon, browser-addon}
#   - `type`     ∈ canonical set (when present)
#   - `platform` items all ∈ canonical set (when present)
#   - `tags`     is an array of strings (when present)
#   - slug (derived from `name`) is unique across all files
#
# Checks (warnings):
#   - `lang` missing or empty
#   - filename stem and slug diverge substantially

require "toml"
require "json"
require "./schema"

include Weapons::Schema

# Specs override `WHW_DATA_DIR` to point at a per-test fixture dir.
WEB_ROOT = ENV["WHW_WEB_ROOT"]? || Path[__DIR__].parent.expand.to_s
DATA_DIR = ENV["WHW_DATA_DIR"]? || Path[WEB_ROOT, "..", "weapons"].expand.to_s

class Finding
  enum Severity
    Error
    Warning
  end

  getter severity : Severity
  getter file : String
  getter message : String

  def initialize(@severity, @file, @message)
  end

  def to_s(io : IO) : Nil
    tag = severity.error? ? "ERROR" : "warn "
    io << "  [" << tag << "] " << file << ": " << message
  end
end

findings = [] of Finding

def err(findings, file, msg)
  findings << Finding.new(Finding::Severity::Error, file, msg)
end

def warn_(findings, file, msg)
  findings << Finding.new(Finding::Severity::Warning, file, msg)
end

def require_string_array(findings, file, key, raw) : Array(String)?
  arr = raw.as_a?
  unless arr
    err(findings, file, "`#{key}` must be an array of strings")
    return nil
  end
  strings = [] of String
  arr.each do |item|
    if s = item.as_s?
      strings << s
    else
      err(findings, file, "`#{key}` contains a non-string value: #{item.raw.inspect}")
    end
  end
  strings
end

seen_slugs = {} of String => String # slug => filename
file_count = 0

Dir.glob(File.join(DATA_DIR, "*.toml")).sort.each do |path|
  file_count += 1
  file = File.basename(path)

  raw = begin
    TOML.parse(File.read(path))
  rescue ex
    err(findings, file, "TOML parse failed: #{ex.message}")
    next
  end

  # name
  name = raw["name"]?.try(&.as_s?).try(&.strip)
  if name.nil? || name.empty?
    err(findings, file, "missing or empty `name`")
    next
  end

  slug = slugify(name)
  if prior = seen_slugs[slug]?
    err(findings, file, "slug '#{slug}' collides with #{prior}")
  else
    seen_slugs[slug] = file
  end

  # filename vs slug sanity (warn only — lots of names diverge by case/punctuation)
  stem_slug = slugify(File.basename(file, ".toml"))
  if stem_slug != slug && !stem_slug.starts_with?(slug) && !slug.starts_with?(stem_slug)
    warn_(findings, file, "filename stem '#{stem_slug}' diverges from name slug '#{slug}'")
  end

  # url (array of strings)
  urls = [] of String
  if url_val = raw["url"]?
    arr = url_val.as_a?
    if arr.nil?
      err(findings, file, "`url` must be an array of strings (got #{url_val.raw.class})")
    else
      arr.each do |item|
        if s = item.as_s?
          s = s.strip
          if s.empty?
            err(findings, file, "`url` contains an empty string")
          elsif !(s.starts_with?("http://") || s.starts_with?("https://"))
            err(findings, file, "`url` entry must start with http:// or https:// (got '#{s}')")
          else
            urls << s
          end
        else
          err(findings, file, "`url` contains a non-string value: #{item.raw.inspect}")
        end
      end
    end
  end

  # source (optional string)
  source = raw["source"]?.try(&.as_s?).try(&.strip)
  if source_raw = raw["source"]?
    if source_raw.as_s?.nil?
      err(findings, file, "`source` must be a string")
    elsif source && !source.empty? && !(source.starts_with?("http://") || source.starts_with?("https://"))
      err(findings, file, "`source` must start with http:// or https:// (got '#{source}')")
    end
  end

  if urls.empty? && (source.nil? || source.empty?)
    err(findings, file, "at least one of `url` or `source` is required")
  end

  # category
  if cat_val = raw["category"]?
    category = cat_val.as_s?
    if category.nil?
      err(findings, file, "`category` must be a string")
    elsif !CATEGORIES.includes?(category)
      err(findings, file, "`category` '#{category}' not in #{CATEGORIES.to_a.sort.join(", ")}")
    end
  else
    err(findings, file, "missing `category`")
  end

  # type (optional but if present must be canonical)
  if type_val = raw["type"]?
    type = type_val.as_s?
    if type.nil?
      err(findings, file, "`type` must be a string")
    elsif !type.empty? && !TYPES.includes?(type)
      err(findings, file, "`type` '#{type}' not in #{TYPES.to_a.sort.join(", ")}")
    end
  end

  # platform (optional; every item must be canonical)
  if plat_val = raw["platform"]?
    plats = require_string_array(findings, file, "platform", plat_val)
    plats.try &.each do |p|
      err(findings, file, "`platform` value '#{p}' not in #{PLATFORMS.to_a.sort.join(", ")}") unless PLATFORMS.includes?(p)
    end
  end

  # tags (optional)
  if tags_val = raw["tags"]?
    require_string_array(findings, file, "tags", tags_val)
  end

  # lang (warn only when missing/empty)
  lang = raw["lang"]?.try(&.as_s?).try(&.strip)
  warn_(findings, file, "`lang` missing or empty") if lang.nil? || lang.empty?
end

errors   = findings.count(&.severity.error?)
warnings = findings.count(&.severity.warning?)

if ARGV.includes?("--json")
  payload = {
    files:    file_count,
    errors:   errors,
    warnings: warnings,
    findings: findings.map { |f|
      {severity: f.severity.to_s.downcase, file: f.file, message: f.message}
    },
  }
  puts payload.to_pretty_json
else
  findings.sort_by! { |f| {f.severity.error? ? 0 : 1, f.file} }
  findings.each { |f| STDOUT.puts f }
  summary = "checked #{file_count} files — #{errors} error(s), #{warnings} warning(s)"
  summary_io = errors > 0 ? STDERR : STDOUT
  summary_io.puts summary
end

exit(errors > 0 ? 1 : 0)
