# `weapons` — terminal client for the WebHackersWeapons catalog.
#
# Consumes the JSON API produced by the sibling `web/` site (same shape as
# `web/public/api/weapons.json`). By default the CLI fetches the live API,
# caches it for 24h under the XDG cache directory, and serves subsequent
# commands from cache.
#
# Data source resolution order (first match wins):
#   1. `--data <path>`            — read a local JSON file (offline dev)
#   2. cache (`~/.cache/weapons/weapons.json`) if fresh and no `--refresh`
#   3. HTTP GET to `--api-url` / env `WEAPONS_API_URL` / DEFAULT_API_URL
#
# The CLI depends only on the Crystal standard library.

require "http/client"
require "json"
require "option_parser"
require "colorize"
require "random"
require "uri"

module Weapons
  VERSION         = "0.1.0"
  DEFAULT_API_URL = "https://weapons.hahwul.com/api/weapons.json"
  CACHE_TTL       = 24.hours
  USER_AGENT      = "weapons-cli/#{VERSION} (+https://github.com/hahwul/WebHackersWeapons)"

  # Single weapon record, mirroring the JSON produced by web/scripts/generate.cr.
  struct Weapon
    include JSON::Serializable

    getter name : String
    getter description : String = ""
    getter url : Array(String) = [] of String
    getter source : String?
    getter category : String = ""
    getter type : String = ""
    getter platform : Array(String) = [] of String
    getter lang : String = ""
    getter tags : Array(String) = [] of String
    getter slug : String
  end

  # Top-level payload wrapping the list. We accept either `{count, weapons}`
  # or a bare array for forward-compat.
  struct Payload
    include JSON::Serializable
    getter count : Int32?
    getter weapons : Array(Weapon)

    def self.from_json_content(raw : String) : Payload
      json = JSON.parse(raw)
      if json.raw.is_a?(Array)
        Payload.from_json({count: json.as_a.size, weapons: json}.to_json)
      else
        Payload.from_json(raw)
      end
    end
  end

  # Raised to abort with a clean message; does NOT print a backtrace.
  class UserError < Exception
  end

  module Cache
    extend self

    def dir : String
      base = ENV["XDG_CACHE_HOME"]? || File.join(ENV["HOME"]? || ".", ".cache")
      File.join(base, "weapons")
    end

    def file : String
      File.join(dir, "weapons.json")
    end

    def fresh?(ttl : Time::Span) : Bool
      return false unless File.exists?(file)
      (Time.utc - File.info(file).modification_time) < ttl
    end

    def read : String
      File.read(file)
    end

    def write(body : String) : Nil
      Dir.mkdir_p(dir)
      File.write(file, body)
    end

    def clear : Nil
      File.delete(file) if File.exists?(file)
    end
  end

  module API
    extend self

    def fetch(url : String) : String
      uri = URI.parse(url)
      if uri.scheme == "file"
        return File.read(uri.path.to_s)
      end

      begin
        response = HTTP::Client.get(
          url,
          headers: HTTP::Headers{
            "User-Agent" => USER_AGENT,
            "Accept"     => "application/json",
          },
        )
      rescue ex : Socket::Error | IO::Error | OpenSSL::SSL::Error
        raise UserError.new("could not reach #{url}: #{ex.message}")
      end

      unless response.success?
        raise UserError.new("API request failed: #{response.status_code} #{response.status_message} (#{url})")
      end
      response.body
    end
  end

  # Dispatcher + shared options, parsed once and passed around as state.
  class Runner
    property api_url : String
    property data_path : String?
    property refresh : Bool = false
    property json_output : Bool = false
    property command : String?
    property positional : Array(String) = [] of String
    property filter_type : String?
    property filter_category : String?
    property filter_lang : String?
    property filter_platform : String?
    property filter_tag : String?
    property limit : Int32 = 0

    def initialize
      @api_url = ENV["WEAPONS_API_URL"]? || DEFAULT_API_URL
    end

    def run(argv : Array(String)) : Int32
      Colorize.enabled = STDOUT.tty? && !argv.includes?("--no-color") && !ENV["NO_COLOR"]?

      parser = build_parser
      parser.parse(argv)

      cmd = @command
      case cmd
      when nil, "help"
        puts parser
        return 0
      when "version"
        puts "weapons #{VERSION}"
        return 0
      when "update"
        Cache.clear
        load_weapons # re-fetches
        STDERR.puts "cache refreshed".colorize(:green)
        return 0
      end

      weapons = load_weapons
      case cmd
      when "search"
        cmd_search(weapons)
      when "list"
        cmd_list(weapons)
      when "info"
        cmd_info(weapons)
      when "random"
        cmd_random(weapons)
      when "category"
        cmd_category(weapons)
      when "stats"
        cmd_stats(weapons)
      when "tags"
        cmd_tags(weapons)
      else
        STDERR.puts "unknown command: #{cmd}".colorize(:red)
        STDERR.puts parser
        return 1
      end
      0
    rescue ex : UserError
      STDERR.puts ex.message.to_s.colorize(:red)
      1
    end

    private def build_parser
      OptionParser.new do |p|
        p.banner = <<-USAGE
          weapons — search the WebHackersWeapons catalog from your terminal.

          Usage: weapons <command> [options]

          Commands:
            search <keyword>   fuzzy-search name/description/tags (respects filters)
            list               list all weapons (respects filters)
            info <name|slug>   print detail on one weapon
            random             print one random weapon (respects filters)
            category <name>    shortcut for `list --category <name>`
            stats              type/lang/category counts
            tags               enumerate every tag with counts
            update             force-refresh the cached JSON
            help               print this help
            version            print CLI version

          Filters (apply to search/list/random):
          USAGE
        p.on("--type TYPE", "filter by type (e.g. Scanner, Recon)") { |v| @filter_type = v }
        p.on("--category CAT", "filter by category (tool, tool-addon, browser-addon)") { |v| @filter_category = v }
        p.on("--lang LANG", "filter by implementation language") { |v| @filter_lang = v }
        p.on("--platform P", "filter by supported platform") { |v| @filter_platform = v }
        p.on("--tag TAG", "filter by tag") { |v| @filter_tag = v }
        p.on("-n N", "--limit N", "cap output to N weapons") { |v| @limit = v.to_i? || 0 }

        p.separator ""
        p.separator "Data source:"
        p.on("--api-url URL", "override API URL (env: WEAPONS_API_URL)") { |v| @api_url = v }
        p.on("--data PATH", "read a local JSON file instead of the API") { |v| @data_path = v }
        p.on("--refresh", "bypass cache and re-fetch") { @refresh = true }

        p.separator ""
        p.separator "Output:"
        p.on("--json", "emit JSON instead of pretty text") { @json_output = true }
        p.on("--no-color", "disable ANSI colors (also respects NO_COLOR)") { Colorize.enabled = false }

        p.separator ""
        p.on("-h", "--help", "show help") do
          puts p
          exit 0
        end
        p.on("-V", "--version", "show version") do
          puts "weapons #{VERSION}"
          exit 0
        end

        p.unknown_args do |args, _|
          next if args.empty?
          @command = args.shift
          @positional = args
        end

        p.invalid_option do |flag|
          STDERR.puts "unknown flag: #{flag}".colorize(:red)
          STDERR.puts p
          exit 1
        end
      end
    end

    # ---- data loading ----

    private def load_weapons : Array(Weapon)
      body = fetch_body
      Payload.from_json_content(body).weapons
    rescue ex : JSON::ParseException
      raise UserError.new("API payload is not valid JSON: #{ex.message}")
    end

    private def fetch_body : String
      if path = @data_path
        raise UserError.new("file not found: #{path}") unless File.exists?(path)
        return File.read(path)
      end

      if !@refresh && Cache.fresh?(CACHE_TTL)
        return Cache.read
      end

      STDERR.puts "fetching #{@api_url}".colorize(:dark_gray) unless @json_output
      body = API.fetch(@api_url)
      Cache.write(body)
      body
    end

    # ---- commands ----

    private def apply_filters(list : Array(Weapon), keyword : String? = nil) : Array(Weapon)
      kw = keyword.try(&.downcase)
      list.select do |w|
        next false if (ft = @filter_type) && w.type.downcase != ft.downcase
        next false if (fc = @filter_category) && w.category.downcase != fc.downcase
        next false if (fl = @filter_lang) && w.lang.downcase != fl.downcase
        next false if (fp = @filter_platform) && !w.platform.map(&.downcase).includes?(fp.downcase)
        next false if (ft2 = @filter_tag) && !w.tags.map(&.downcase).includes?(ft2.downcase)
        if kw
          haystack = "#{w.name} #{w.description} #{w.tags.join(" ")} #{w.type} #{w.lang}".downcase
          next false unless haystack.includes?(kw)
        end
        true
      end
    end

    private def cmd_search(weapons)
      kw = @positional.first?
      raise UserError.new("usage: weapons search <keyword> [filters]") if kw.nil? || kw.empty?
      results = apply_filters(weapons, kw)
      emit_list(results, header: "#{results.size} match(es) for \"#{kw}\"")
    end

    private def cmd_list(weapons)
      results = apply_filters(weapons)
      emit_list(results, header: "#{results.size} of #{weapons.size} weapons")
    end

    private def cmd_category(weapons)
      name = @positional.first?
      raise UserError.new("usage: weapons category <name>") if name.nil?
      @filter_category = name
      results = apply_filters(weapons)
      emit_list(results, header: "category: #{name} (#{results.size})")
    end

    private def cmd_info(weapons)
      query = @positional.first?
      raise UserError.new("usage: weapons info <name|slug>") if query.nil?
      needle = query.downcase
      hit = weapons.find { |w| w.slug == needle } ||
            weapons.find { |w| w.name.downcase == needle } ||
            weapons.find { |w| w.slug.includes?(needle) } ||
            weapons.find { |w| w.name.downcase.includes?(needle) }
      raise UserError.new("no weapon matches '#{query}'") unless hit

      if @json_output
        puts hit.to_pretty_json
      else
        print_detail(hit)
      end
    end

    private def cmd_random(weapons)
      pool = apply_filters(weapons)
      raise UserError.new("no weapons match the current filters") if pool.empty?
      pick = pool.sample
      if @json_output
        puts pick.to_pretty_json
      else
        print_detail(pick)
      end
    end

    private def cmd_stats(weapons)
      if @json_output
        payload = {
          count:      weapons.size,
          types:      count_by(weapons) { |w| w.type.empty? ? "Unknown" : w.type },
          languages:  count_by(weapons) { |w| w.lang.empty? ? "Unknown" : w.lang },
          categories: count_by(weapons) { |w| w.category },
        }
        puts payload.to_pretty_json
        return
      end

      puts "Total: #{weapons.size.to_s.colorize(:cyan).bold}"
      print_bucket("Type", count_by(weapons) { |w| w.type.empty? ? "Unknown" : w.type })
      print_bucket("Language", count_by(weapons) { |w| w.lang.empty? ? "Unknown" : w.lang })
      print_bucket("Category", count_by(weapons) { |w| w.category })
    end

    private def cmd_tags(weapons)
      counts = {} of String => Int32
      weapons.each do |w|
        w.tags.each { |t| counts[t] = (counts[t]? || 0) + 1 }
      end
      if @json_output
        puts counts.to_pretty_json
        return
      end
      print_bucket("Tags", counts)
    end

    # ---- rendering ----

    private def emit_list(list : Array(Weapon), header : String)
      list = list[0, @limit] if @limit > 0 && list.size > @limit

      if @json_output
        puts list.to_pretty_json
        return
      end

      STDERR.puts "# #{header}".colorize(:dark_gray) if STDOUT.tty?

      if list.empty?
        STDERR.puts "  (no matches)".colorize(:yellow)
        return
      end

      name_w = Math.min(32, list.max_of { |w| w.name.size })
      type_w = Math.min(14, list.max_of { |w| w.type.size.clamp(1, 14) })
      lang_w = Math.min(12, list.max_of { |w| w.lang.size.clamp(1, 12) })

      list.each do |w|
        name_str = w.name.ljust(name_w)
        type_str = (w.type.empty? ? "-" : w.type).ljust(type_w)
        lang_str = (w.lang.empty? ? "-" : w.lang).ljust(lang_w)
        desc = w.description.size > 80 ? w.description[0, 77] + "…" : w.description
        print name_str.colorize(:cyan).bold
        print "  "
        print type_str.colorize(:magenta)
        print "  "
        print lang_str.colorize(:yellow)
        print "  "
        puts desc
      end
    end

    private def print_detail(w : Weapon)
      puts w.name.colorize(:cyan).bold
      puts w.description unless w.description.empty?
      puts ""
      puts "  slug:     #{w.slug}"
      puts "  type:     #{w.type.empty? ? "-" : w.type}"
      puts "  lang:     #{w.lang.empty? ? "-" : w.lang}"
      puts "  category: #{w.category}"
      puts "  platform: #{w.platform.empty? ? "-" : w.platform.join(", ")}"
      puts "  tags:     #{w.tags.empty? ? "-" : w.tags.join(", ")}"
      if src = w.source
        puts "  source:   #{src.colorize(:blue)}"
      end
      unless w.url.empty?
        puts "  links:    #{w.url.first.colorize(:blue)}"
        w.url[1..].each { |u| puts "            #{u.colorize(:blue)}" }
      end
    end

    private def print_bucket(label : String, counts : Hash(String, Int32))
      puts label.colorize(:cyan).bold
      return if counts.empty?
      totals = counts.to_a.sort_by! { |(_, v)| -v }
      width = totals.max_of { |(k, _)| k.size }
      totals.each do |(k, v)|
        printf("  %-#{width}s  %d\n", k, v)
      end
    end

    private def count_by(list : Array(Weapon), &block : Weapon -> String) : Hash(String, Int32)
      counts = {} of String => Int32
      list.each do |w|
        k = block.call(w)
        counts[k] = (counts[k]? || 0) + 1
      end
      counts
    end
  end
end

exit Weapons::Runner.new.run(ARGV)
