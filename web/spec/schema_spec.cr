require "./spec_helper"
require "../scripts/schema"

include Weapons::Schema

describe Weapons::Schema do
  describe ".slugify" do
    it "lowercases and dashes non-alphanumerics" do
      slugify("Amass").should eq "amass"
      slugify("OWASP ZAP").should eq "owasp-zap"
      slugify("3klCon").should eq "3klcon"
    end

    it "collapses runs of separators and trims edges" do
      slugify("  Foo // Bar  ").should eq "foo-bar"
      slugify("__A__B__").should eq "a-b"
    end

    it "yields empty string when nothing alphanumeric remains" do
      slugify("!!!").should eq ""
      slugify("   ").should eq ""
    end
  end

  describe ".toml_escape" do
    it "doubles backslashes and escapes double quotes" do
      toml_escape(%q(SSL\TLS)).should eq %q(SSL\\TLS)
      toml_escape(%q(She said "hi")).should eq %q(She said \"hi\")
    end

    it "flattens control whitespace into a single space" do
      toml_escape("a\nb\tc\r\nd").should eq "a b c  d"
    end

    it "trims leading and trailing whitespace" do
      toml_escape("  padded  ").should eq "padded"
    end
  end

  describe ".toml_array" do
    it "renders empty arrays" do
      toml_array([] of String).should eq "[]"
    end

    it "quotes every element" do
      toml_array(["a", "b"]).should eq %q(["a", "b"])
    end

    it "escapes dangerous chars inside elements" do
      toml_array([%q(a"b), %q(c\d)]).should eq %q(["a\"b", "c\\d"])
    end
  end

  describe "canonical value sets" do
    it "categories covers the documented three" do
      CATEGORIES.should eq Set{"tool", "tool-addon", "browser-addon"}
    end

    it "types disallow casing variants" do
      TYPES.includes?("Utils").should be_true
      TYPES.includes?("utils").should be_false
      TYPES.includes?("Army-Knife").should be_true
      TYPES.includes?("Army-knife").should be_false
    end

    it "platforms include OS, browser, and host-tool targets" do
      %w(linux macos windows firefox chrome safari burpsuite zap caido).each do |p|
        PLATFORMS.includes?(p).should be_true
      end
    end
  end
end
