Pod::Spec.new do |s|

  s.name         = "BRDatabase"
  s.version      = "0.1.0"
  s.summary      = "This framework is an extension of FMDB that provides versioning for database upgrades."
  s.homepage     = "https://github.com/BelovedRobot/BRDatabase"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.authors      = { "Beloved Robot LLC" => "belovedrobot@gmail.com", "Zane Kellog => "zane@belovedrobot.com" }
  s.source       = { :git => "https://github.com/BelovedRobot/BRDatabase.git", :tag => "v0.1.0" }
  s.source_files = "BRDatabase/BRDatabase.{h,m}", "BRDatabase/FMDatabase_BRDatabaseExtensions.{h,m}"

end
