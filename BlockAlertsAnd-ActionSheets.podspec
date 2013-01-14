Pod::Spec.new do |s|
  s.name		= 'BlockAlertsAnd-ActionSheets'
  s.version		= '1.0.1'
  s.license		= 'MIT'
  s.summary		= 'UIAlertView and UIActionSheet replacements'
  s.homepage	= 'https://github.com/levigroker/BlockAlertsAnd-ActionSheets'
  s.author		= { "Levi Brown" => "levigroker@gmail.com" }
  s.source		= { :git => 'https://github.com/levigroker/BlockAlertsAnd-ActionSheets.git', :tag => '1.0.0' }
  s.description	= 'UIAlertView and UIActionSheet replacements'
  s.platform	= :ios, '5.0'
  s.ios.deployment_target = '5.0'
  s.requires_arc	= true
  s.source_files = 'BlockAlertsDemo/ToAddToYourProjects', 'BlockAlertsDemo/ProjectSpecific/BlockUI.h'
  s.resources =	"BlockAlertsDemo/images/ActionSheet/*.png", "BlockAlertsDemo/images/AlertView/*.png"
end