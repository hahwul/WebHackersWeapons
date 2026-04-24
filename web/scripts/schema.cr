# Shared schema definitions for the weapon data model.
#
# `generate.cr` and `validate.cr` both need to agree on:
#   - canonical value sets for category / type / platform
#   - slug derivation
#   - TOML-string escape rules used when we emit front matter
#
# Keeping a single copy here prevents silent drift — e.g. adding a new
# platform to the validator but forgetting the generator's allow-list.

module Weapons::Schema
  extend self

  CATEGORIES = Set{"tool", "tool-addon", "browser-addon"}

  TYPES = Set{
    "Utils", "Recon", "Scanner", "Fuzzer",
    "Exploit", "Proxy", "Army-Knife", "Env",
  }

  PLATFORMS = Set{
    "linux", "macos", "windows",
    "firefox", "chrome", "safari",
    "burpsuite", "zap", "caido",
  }

  # URL segment derived from a weapon's display name — lowercased,
  # non-alphanumerics collapsed to dashes, leading/trailing dashes trimmed.
  def slugify(name : String) : String
    name.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/(^-|-$)/, "")
  end

  # Escape a string for use inside a single-line TOML basic string
  # (between double quotes). Backslashes and quotes must be escaped;
  # raw newlines/tabs are not allowed in basic strings.
  def toml_escape(str : String) : String
    str
      .gsub("\\", "\\\\")
      .gsub("\"", "\\\"")
      .gsub(/[\r\n\t]/, " ")
      .strip
  end

  # Render an array of strings as a TOML inline array literal.
  def toml_array(arr : Array(String)) : String
    "[" + arr.map { |v| %("#{toml_escape(v)}") }.join(", ") + "]"
  end
end
