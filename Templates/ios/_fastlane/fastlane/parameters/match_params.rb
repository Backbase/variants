
# REPLACE WITH ENVIRONMENT VARIABLES

# Name and password for Match temporary keychain
MATCH_PARAMS = {
  MATCH_KEYCHAIN_NAME: 'sample-match-keychain', # ENV['MATCH_KEYCHAIN_NAME']
  MATCH_KEYCHAIN_PASSWORD: 'sample-77hamcj819oak', # ENV['MATCH_KEYCHAIN_PASSWORD']
  
  # This is needed if your Match repository is private
  MATCH_GIT_BASIC_AUTHORIZATION: ENV['MATCH_GIT_BASIC_AUTHORIZATION'],
  
  # Match repository password, used to decrypt files
  MATCH_PASSWORD: ENV['MATCH_PASSWORD'],
  
  CODE_SIGNING_IDENTITY: 'iPhone Distribution: BACKBASE EUROPE B.V.',
  EXPORT_METHOD: 'enterprise'
}.freeze
