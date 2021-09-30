require 'builder'
require 'httparty'
require 'json'
require 'fileutils'

raise "CHOCO_README.md is too long. Limit is 4000 chars for choco pacakges. 🤷‍♂️" if File.read('CHOCO_README.md').to_s.length > 4000

res = HTTParty.get('https://api.github.com/repos/rainforestapp/rainforest-cli/releases')
raise StandardError, "🚨 Error #{res.code} while fetching releases:\n#{res.body}" unless res.code == 200

releases = JSON.parse(res.body)

latest_release = releases.find do |release|
  !release['draft'] && !release['prerelease']
end


class Release
  attr_reader :release

  def initialize(release)
    @release = release
  end

  def version
    @release['tag_name'][1..-1]
  end

  def windows_amd64_zip_name
    "rainforest-cli-#{version}-windows-amd64.zip"
  end

  def windows_amd64
    find_asset(windows_amd64_zip_name)
  end

  def checksums
    find_asset('checksums.txt')
  end

  def download(asset, checksum = nil)
    if checksum
      `aria2c #{asset['browser_download_url']} --allow-overwrite=true --checksum=sha-256=#{checksum}`
    else
      `aria2c #{asset['browser_download_url']} --allow-overwrite=true`
    end
  end

  private
  def find_asset(asset_name)
    release['assets'].find do |asset|
      asset['name'] == asset_name
    end
  end
end

def get_checksum(asset_name)
  File.read('checksums.txt').split("\n").find do |line|
    line.split("  ")[1] == asset_name
  end.split("  ")[0]
end

latest_release = Release.new(latest_release)

puts "Building 🍫 Chocolatey package for #{latest_release.version}"

unless File.exists?(File.basename(latest_release.windows_amd64['browser_download_url']))
  print "- Fetching release checksums "
  latest_release.download(latest_release.checksums)
  puts "✅"

  print "- Fetching #{latest_release.windows_amd64_zip_name} "
  latest_release.download(latest_release.windows_amd64, get_checksum(latest_release.windows_amd64_zip_name))
  puts "✅"
else
  puts "- Using cached archive - should only see this in dev 🧐"
end

print "- Setting up folders "
# unzip, move
FileUtils.rm_rf('tmp')
FileUtils.rm_rf('rainforest-cli')
FileUtils.mkdir_p('tmp')
FileUtils.mkdir_p(File.join('rainforest-cli', 'tools'))
puts "✅"

print "- Unzipping #{latest_release.windows_amd64_zip_name} "
print "\tunzip -n #{latest_release.windows_amd64_zip_name} -d tmp"
`unzip -n #{latest_release.windows_amd64_zip_name} -d tmp`
puts "✅"

print "- Moving exe --> package "
FileUtils.mv(File.join('tmp', 'rainforest.exe'), File.join('rainforest-cli', 'tools'))
puts "✅"


print "- Moving LICENSE --> package "
FileUtils.cp(File.join('LICENSE'), File.join('rainforest-cli', 'tools', 'LICENSE.txt'))
puts "✅"

exe = File.join('rainforest-cli', 'tools', 'rainforest.exe')
exe_checksum = Gem::Platform.local.os == 'darwin' ? `md5sum #{exe}` : `Get-FileHash #{exe}`

print "- Writing VERIFICATION --> package "
File.write(File.join('rainforest-cli', 'tools', 'VERIFICATION.txt'), "
VERIFICATION
Verification is intended to assist the Chocolatey moderators and community
in verifying that this package's contents are trustworthy.

This package is published by the Rainforest QA itself. Any binaries will be identical to other package types published by the project, and can be built from source if you wish from https://github.com/rainforestapp/rainforest-cli or view the build artifacts directly from the releases page at https://github.com/rainforestapp/rainforest-cli/releases.

Manually checking the expected checksum:
Get-FileHash rainforest.exe

Expected:
#{exe_checksum}")
puts "✅"

print "- Making rainforest-cli.nuspec "
# write the nuget
builder = Builder::XmlMarkup.new(indent: 2)
builder.instruct!(:xml, version: '1.0', encoding: 'UTF-8')

xml = builder.package(xmlns: 'http://schemas.microsoft.com/packaging/2015/06/nuspec.xsd') do |package|
  package.metadata do |metadata|
    metadata.title('Rainforest CLI')
    metadata.id('rainforest-cli')
    metadata.version(latest_release.version)
    metadata.summary('A command line interface to interact with Rainforest QA - https://www.rainforestqa.com/.')
    metadata.tags('rainforest-cli rainforest')
    metadata.owners('@ukd1')

    metadata.packageSourceUrl('https://github.com/rainforestapp/rainforest-cli-chocolatey')
    metadata.authors('https://github.com/rainforestapp/rainforest-cli/graphs/contributors')
    metadata.projectUrl('https://www.rainforestqa.com')
    metadata.iconUrl('https://assets.website-files.com/60da68c37e57671c365004bd/60da68c37e576749595005ae_favicon-large.svg')
    metadata.copyright('2021 Rainforest QA, Inc')

    metadata.licenseUrl('https://github.com/rainforestapp/rainforest-cli/blob/master/LICENSE.txt')
    metadata.requireLicenseAcceptance(true)
    metadata.projectSourceUrl('https://github.com/rainforestapp/rainforest-cli')
    metadata.docsUrl('https://github.com/rainforestapp/rainforest-cli/blob/master/README.md')
    metadata.bugTrackerUrl('https://github.com/rainforestapp/rainforest-cli/issues')
    metadata.description(File.read('CHOCO_README.md').to_s)
    # metadata.releaseNotes(File.read('../CHANGELOG.md').to_s[0..3999])
  end

  package.files do |files|
    files.file(src: 'tools/rainforest.exe', target: 'rainforest.exe')
  end
end
puts "✅"

File.write(File.join('rainforest-cli', 'rainforest-cli.nuspec'), xml)

puts "Done 👋🏻"