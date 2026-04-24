require "spec"
require "file_utils"
require "json"

WEB_DIR     = File.expand_path("..", __DIR__)
SCRIPTS_DIR = File.join(WEB_DIR, "scripts")
FIXTURES    = File.join(__DIR__, "fixtures")

# Run one of the top-level scripts as a subprocess and capture the result.
# `data_dir` / `web_root` override the canonical locations so the script
# operates on a temp tree instead of the real weapons/ and web/ dirs.
def run_script(
  script : String,
  script_args : Array(String) = [] of String,
  data_dir : String? = nil,
  web_root : String? = nil,
) : {Int32, String, String}
  env = {} of String => String
  env["WHW_DATA_DIR"] = data_dir if data_dir
  env["WHW_WEB_ROOT"] = web_root if web_root

  stdout = IO::Memory.new
  stderr = IO::Memory.new
  status = Process.run(
    "crystal",
    args: ["run", "--no-color", File.join(SCRIPTS_DIR, script), "--"] + script_args,
    output: stdout,
    error: stderr,
    env: env,
    chdir: WEB_DIR,
  )
  {status.exit_code, stdout.to_s, stderr.to_s}
end

# Minimal valid weapon TOML for use in fixtures. Callers pass overrides as
# keyword args to inject a schema violation.
def weapon_toml(
  name : String = "Amass",
  description : String = "Asset discovery tool.",
  url : String = "https://github.com/OWASP/Amass",
  category : String = "tool",
  type : String = "Recon",
  platform : String = %q(["linux", "macos", "windows"]),
  lang : String = "Go",
  tags : String = %q([]),
  extra : String = "",
) : String
  <<-TOML
  name = "#{name}"
  description = "#{description}"
  url = ["#{url}"]
  category = "#{category}"
  type = "#{type}"
  platform = #{platform}
  lang = "#{lang}"
  tags = #{tags}
  #{extra}
  TOML
end

# Create an isolated weapons dir + web root under a temp path and yield both.
def with_fixture_dirs(&)
  base = File.tempname("whw-spec-")
  data_dir = File.join(base, "weapons")
  web_root = File.join(base, "web")
  FileUtils.mkdir_p(data_dir)
  FileUtils.mkdir_p(File.join(web_root, "content", "weapons"))
  FileUtils.mkdir_p(File.join(web_root, "static"))
  FileUtils.mkdir_p(File.join(web_root, "data"))
  # The generator clears content/weapons/*.md except _index.md — give it one
  # to preserve so we exercise the normal code path.
  File.write(File.join(web_root, "content", "weapons", "_index.md"), "+++\ntitle = \"Weapons\"\n+++\n")
  begin
    yield data_dir, web_root
  ensure
    FileUtils.rm_rf(base)
  end
end
