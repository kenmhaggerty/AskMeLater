# Podfile
# PushQuery
# Ken M. Haggerty
# CREATED: ???????????
# EDITED:  ???????????

source 'https://github.com/CocoaPods/Specs.git'

target "PushQuery" do
  pod 'Firebase/Messaging'
  pod 'Firebase/Database'
  pod 'Firebase/Crash'
  pod 'Firebase/Auth'
  pod 'PNChart'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'JDStatusBarNotification'
end

def test_pods
  pod 'Specta', '~> 1.0'
  pod 'Expecta', '~> 1.0'
  pod 'Expecta+Collections'                                              
  pod 'Swizzlean', '~> 0.2'
  pod 'KIF', '~> 3.0'
  pod 'KIFViewControllerActions'
end

target "PushQueryTests" do
  test_pods
end

target "PushQueryUITests" do
  test_pods
end
