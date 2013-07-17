Pod::Spec.new do |s|
  s.name		= 'BlockAlertsAnd-ActionSheets'
  s.version		= '1.0.6'
  s.license		= 'MIT'
  s.summary		= 'UIAlertView and UIActionSheet replacements'
  s.homepage	= 'https://github.com/levigroker/BlockAlertsAnd-ActionSheets'
  s.author		= { "Levi Brown" => "levigroker@gmail.com" }
  s.source		= { :git => 'https://github.com/levigroker/BlockAlertsAnd-ActionSheets.git', :tag => '#{s.version}.1' }
  s.description	= 'UIAlertView and UIActionSheet replacements'
  s.platform	= :ios, '5.0'
  s.ios.deployment_target = '5.0'
  s.requires_arc	= true
  s.source_files =  "BlockAlertsDemo/ToAddToYourProjects/BlockActionSheet.{h,m}", "BlockAlertsDemo/ToAddToYourProjects/BlockAlertView.{h,m}", "BlockAlertsDemo/ToAddToYourProjects/BlockBackground.{h,m}", "BlockAlertsDemo/ToAddToYourProjects/BlockTextPromptAlertView.{h,m}", 'BlockAlertsDemo/ProjectSpecific/BlockUI.h'
  s.resources = "BlockAlertsDemo/images/*.png", "BlockAlertsDemo/images/ActionSheet/*.png", "BlockAlertsDemo/images/AlertView/*.png"

  s.subspec 'TableAlertView' do |table|
    table.source_files = "BlockAlertsDemo/ToAddToYourProjects/BlockTableAlertView.{h,m}"
  end
end
