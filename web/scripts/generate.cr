# Pre-build generator: reads ../weapons/*.toml (repo-root canonical data),
# writes per-weapon markdown into content/weapons/, JSON endpoints into
# static/api/, and site.data source at data/weapons.json.
#
# Run via `crystal run scripts/generate.cr` from the web/ directory.
# Wired as a pre-build hook in config.toml.
#
# Requires the `toml` shard (see web/shard.yml). Run `shards install` once.

require "toml"
require "json"
require "file_utils"
require "./schema"

include Weapons::Schema

WEB_ROOT    = Path[__DIR__].parent.expand.to_s            # .../web
DATA_DIR    = Path[WEB_ROOT, "..", "weapons"].expand.to_s # .../weapons
CONTENT_DIR = File.join(WEB_ROOT, "content", "weapons")
API_DIR     = File.join(WEB_ROOT, "static", "api")
API_TOOLS   = File.join(API_DIR, "weapons")
SITE_DATA   = File.join(WEB_ROOT, "data")

FileUtils.mkdir_p(CONTENT_DIR)
FileUtils.mkdir_p(API_TOOLS)
FileUtils.mkdir_p(SITE_DATA)

# Clear previously generated detail pages (keep _index.md).
Dir.glob(File.join(CONTENT_DIR, "*.md")).each do |f|
  next if File.basename(f) == "_index.md"
  File.delete(f)
end
Dir.glob(File.join(API_TOOLS, "*.json")).each { |f| File.delete(f) }

# A weapon, in canonical form. Field order matches JSON output.
struct Weapon
  include JSON::Serializable

  property name : String
  property description : String
  property url : Array(String)
  property source : String?
  property category : String
  property type : String
  property platform : Array(String)
  property lang : String
  property tags : Array(String)
  property slug : String

  def initialize(@name, @description, @url, @source, @category, @type,
                 @platform, @lang, @tags, @slug)
  end

  def self.from_toml(raw : TOML::Table) : Weapon?
    name = raw["name"]?.try(&.as_s?).try(&.strip)
    return nil if name.nil? || name.empty?

    description = (raw["description"]?.try(&.as_s?) || "").strip
    url = url_list(raw["url"]?)
    source = raw["source"]?.try(&.as_s?).try(&.strip)
    source = nil if source.try(&.empty?)
    # `category` is required — no silent default. Validator catches the
    # schema violation with a nicer message; we fail fast so a broken
    # local build can't quietly publish invalid data.
    category = raw["category"]?.try(&.as_s?)
    raise "#{name}: missing or invalid `category`" if category.nil? || category.empty?
    raise "#{name}: `category` '#{category}' not in #{CATEGORIES.to_a.sort}" unless CATEGORIES.includes?(category)
    type = raw["type"]?.try(&.as_s?) || ""
    lang = raw["lang"]?.try(&.as_s?) || ""
    platform = string_array(raw["platform"]?)
    tags = string_array(raw["tags"]?).map(&.strip).reject(&.empty?)

    new(
      name: name,
      description: description,
      url: url,
      source: source,
      category: category,
      type: type,
      platform: platform,
      lang: lang,
      tags: tags,
      slug: slugify(name),
    )
  end

  # Accepts url as either a single string (legacy) or an array of strings.
  private def self.url_list(value : TOML::Any?) : Array(String)
    return [] of String unless value
    case raw = value.raw
    when String
      s = raw.strip
      s.empty? ? [] of String : [s]
    when Array
      raw.compact_map(&.as_s?).map(&.strip).reject(&.empty?)
    else
      [] of String
    end
  end

  private def self.string_array(value : TOML::Any?) : Array(String)
    return [] of String unless value
    arr = value.as_a?
    return [] of String unless arr
    arr.compact_map(&.as_s?)
  end
end

weapons    = [] of Weapon
errors     = 0
seen_slugs = {} of String => String

Dir.glob(File.join(DATA_DIR, "*.toml")).sort.each do |path|
  raw = begin
    TOML.parse(File.read(path))
  rescue ex
    STDERR.puts "skip #{File.basename(path)}: #{ex.message}"
    errors += 1
    next
  end

  weapon = begin
    Weapon.from_toml(raw)
  rescue ex
    STDERR.puts "error: #{File.basename(path)}: #{ex.message}"
    exit 1
  end
  next unless weapon

  if prior = seen_slugs[weapon.slug]?
    STDERR.puts "slug collision: #{File.basename(path)} shadows #{prior} (both slug '#{weapon.slug}')"
    next
  end
  seen_slugs[weapon.slug] = File.basename(path)

  # Per-weapon JSON endpoint.
  File.write(
    File.join(API_TOOLS, "#{weapon.slug}.json"),
    weapon.to_pretty_json,
  )

  # Per-weapon detail markdown.
  desc_short = weapon.description[0, Math.min(160, weapon.description.size)]
  fallback_tags = [weapon.type, weapon.lang].reject(&.empty?)
  display_tags = weapon.tags.empty? ? fallback_tags : weapon.tags

  lines = [] of String
  lines << "+++"
  lines << %(title = "#{toml_escape(weapon.name)}")
  lines << %(description = "#{toml_escape(desc_short)}") unless desc_short.empty?
  lines << %(template = "weapon")
  lines << "tags = #{toml_array(display_tags.uniq)}" unless display_tags.empty?
  # Hwaro maps unknown top-level TOML keys into page.extra.<key>. A nested
  # [extra] subtable does NOT work — the parser stringifies it under
  # page.extra.extra. Keep custom fields flat at the top level.
  #
  # We intentionally do NOT emit `name` here — hwaro's front-matter typo
  # detector treats `name` as a probable misspelling of `date` (levenshtein
  # 2) and warns twice per page. `page.title` already holds the weapon's
  # name; templates use it directly.
  lines << "url = #{toml_array(weapon.url)}"
  if src = weapon.source
    lines << %(source = "#{toml_escape(src)}")
  end
  lines << %(category = "#{toml_escape(weapon.category)}")
  lines << %(type = "#{toml_escape(weapon.type)}")
  lines << %(lang = "#{toml_escape(weapon.lang)}")
  lines << "platform = #{toml_array(weapon.platform)}"
  lines << "raw_tags = #{toml_array(weapon.tags)}"
  lines << %(api = "/api/weapons/#{weapon.slug}.json")
  lines << "+++"
  lines << ""
  lines << weapon.description unless weapon.description.empty?
  lines << ""

  File.write(File.join(CONTENT_DIR, "#{weapon.slug}.md"), lines.join("\n"))
  weapons << weapon
end

weapons.sort_by! { |w| w.name.downcase }

# Global list endpoint.
File.write(
  File.join(API_DIR, "weapons.json"),
  {count: weapons.size, weapons: weapons}.to_pretty_json,
)

# site.data.weapons — Hwaro loads data/*.json automatically.
# A symlinked data/weapons/ directory does NOT work (Crystal's Dir.glob
# does not follow symlinks), so we dump a flat array here and iterate it
# in templates as `site.data.weapons`.
File.write(File.join(SITE_DATA, "weapons.json"), weapons.to_json)

# Lightweight stats endpoint.
def count_by(weapons : Array(Weapon), &) : Hash(String, Int32)
  weapons.each_with_object({} of String => Int32) do |w, h|
    key = yield w
    h[key] = (h[key]? || 0) + 1
  end
end

stats = {
  count:      weapons.size,
  types:      count_by(weapons) { |w| w.type.empty? ? "Unknown" : w.type },
  languages:  count_by(weapons) { |w| w.lang.empty? ? "Unknown" : w.lang },
  categories: count_by(weapons) { |w| w.category },
}
File.write(File.join(API_DIR, "stats.json"), stats.to_pretty_json)

puts "generated #{weapons.size} weapons (#{errors} errors)"
