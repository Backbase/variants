

PROJECT_PARAMS = {
  app_scheme: 'ragnarok-us-app',
  test_scheme: 'ragnarok-us-app',
  uitest_scheme: 'ragnarok-us-app-ui-tests',
  derived_data_path: '.derivedData',
  ui_test_reports_folder: './ui-test-results',
  swiftlint_path: './.swiftlint.yml',
  test_devices: ['iPhone 11'],
  ui_test_destination: "platform=iOS Simulator,name=#{ENV["DEVICE"]},OS=#{ENV["OS"]}",
  ui_test_plan: 'Regression',
  workspace: 'ragnarok-app.xcworkspace',
  
  REPORTS_FOLDER: './reports',
  COHERENT_SPEC: '../coherent-swift.yml'
}.freeze
