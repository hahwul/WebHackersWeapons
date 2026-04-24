#!/usr/bin/env ruby
# Generate per-weapon markdown pages and JSON API files from data/weapons/*.yaml.
# Runs as a pre-build hook so `site.data.weapons` stays canonical and
# detail pages / JSON endpoints are rebuilt from the same source.

require "yaml"
require "json"
require "fileutils"

ROOT        = File.expand_path("..", __dir__)
# Canonical weapon YAMLs live at the repo root (../weapons from the web/ dir).
DATA_DIR    = File.expand_path("../weapons", ROOT)
CONTENT_DIR = File.join(ROOT, "content", "weapons")
API_DIR     = File.join(ROOT, "static", "api")
API_TOOLS   = File.join(API_DIR, "weapons")
SITE_DATA   = File.join(ROOT, "data")

FileUtils.mkdir_p(CONTENT_DIR)
FileUtils.mkdir_p(API_TOOLS)
FileUtils.mkdir_p(SITE_DATA)

# Clear previously generated detail pages (but keep _index.md).
Dir.glob(File.join(CONTENT_DIR, "*.md")).each do |f|
  next if File.basename(f) == "_index.md"
  File.delete(f)
end
Dir.glob(File.join(API_TOOLS, "*.json")).each { |f| File.delete(f) }

def slugify(name)
  name.to_s.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/^-|-$/, "")
end

def normalize(w)
  {
    "name"        => w["name"].to_s,
    "description" => w["description"].to_s.strip,
    "url"         => w["url"].to_s,
    "category"    => (w["category"] || "tool").to_s,
    "type"        => (w["type"] || "").to_s,
    "platform"    => Array(w["platform"]).map(&:to_s),
    "lang"        => w["lang"].to_s,
    "tags"        => Array(w["tags"]).map { |t| t.to_s.strip }.reject(&:empty?),
  }
end

def toml_escape(str)
  str.to_s
     .gsub("\\") { "\\\\" }
     .gsub('"')  { '\\"' }
     .gsub(/[\r\n\t]/, " ")
     .strip
end

def toml_array(arr)
  "[" + arr.map { |v| %("#{toml_escape(v)}") }.join(", ") + "]"
end

weapons    = []
errors     = 0
seen_slugs = {}

Dir.glob(File.join(DATA_DIR, "*.yaml")).sort.each do |path|
  begin
    raw = YAML.load_file(path)
  rescue => e
    warn "skip #{File.basename(path)}: #{e.message}"
    errors += 1
    next
  end
  next unless raw.is_a?(Hash)
  next if raw["name"].to_s.strip.empty?

  w    = normalize(raw)
  slug = slugify(w["name"])
  w["slug"] = slug

  if seen_slugs[slug]
    warn "slug collision: #{File.basename(path)} shadows #{seen_slugs[slug]} (both slug '#{slug}')"
    next
  end
  seen_slugs[slug] = File.basename(path)

  # Per-weapon JSON endpoint.
  File.write(File.join(API_TOOLS, "#{slug}.json"), JSON.pretty_generate(w))

  # Per-weapon detail markdown. Store full data under [extra] for the template.
  desc_short = w["description"][0, 160]
  tags = w["tags"].empty? ? [w["type"], w["lang"]].reject(&:empty?) : w["tags"]

  lines = []
  lines << "+++"
  lines << %(title = "#{toml_escape(w["name"])}")
  lines << %(description = "#{toml_escape(desc_short)}") unless desc_short.empty?
  lines << "template = \"weapon\""
  lines << "tags = #{toml_array(tags.uniq)}" unless tags.empty?
  # Hwaro turns every unknown top-level key into page.extra.<key>. A nested
  # [extra] subtable does NOT work — the parser stringifies it under
  # page.extra.extra. Keep custom fields flat at the top level.
  lines << %(name = "#{toml_escape(w["name"])}")
  lines << %(url = "#{toml_escape(w["url"])}")
  lines << %(category = "#{toml_escape(w["category"])}")
  lines << %(type = "#{toml_escape(w["type"])}")
  lines << %(lang = "#{toml_escape(w["lang"])}")
  lines << "platform = #{toml_array(w["platform"])}"
  lines << "raw_tags = #{toml_array(w["tags"])}"
  lines << %(api = "#{toml_escape("/api/weapons/#{slug}.json")}")
  lines << "+++"
  lines << ""
  lines << w["description"] unless w["description"].empty?
  lines << ""

  File.write(File.join(CONTENT_DIR, "#{slug}.md"), lines.join("\n"))
  weapons << w
end

# Global list JSON endpoint (sorted by name, case-insensitive).
weapons.sort_by! { |w| w["name"].downcase }
File.write(File.join(API_DIR, "weapons.json"), JSON.pretty_generate({
  "count"   => weapons.length,
  "weapons" => weapons,
}))

# site.data.weapons — Hwaro reads data/*.json automatically. We dump the
# flat array here so templates can iterate `site.data.weapons` directly.
# (A symlinked data/weapons/ directory does NOT work because Crystal's
# Dir.glob does not follow symlinks.)
File.write(File.join(SITE_DATA, "weapons.json"), JSON.generate(weapons))

# Light stats endpoint — handy for dashboards or the homepage.
stats = {
  "count"      => weapons.length,
  "types"      => weapons.group_by { |w| w["type"].empty? ? "Unknown" : w["type"] }.transform_values(&:length),
  "languages"  => weapons.group_by { |w| w["lang"].empty?  ? "Unknown" : w["lang"]  }.transform_values(&:length),
  "categories" => weapons.group_by { |w| w["category"] }.transform_values(&:length),
}
File.write(File.join(API_DIR, "stats.json"), JSON.pretty_generate(stats))

puts "generated #{weapons.length} weapons (#{errors} errors)"
