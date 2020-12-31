<h3 align="center">
  <a href="https://github.com/andydotdaniel/dozy/blob/main/dozy_banner.png">
  <img src="https://github.com/andydotdaniel/dozy/blob/main/dozy_banner.png?raw=true" alt="Dozy Banner" width="120">
  </a>
</h3>

# Dozy
Dozy is an iOS app that helps you wake up more consistently in the morning. Create your own eyebrow-raising message (text or image), and set a time for you to verify that you're awake. If you fail to show Dozy that you're awake, that message gets set to a pre-selected Slack channel!

## Prerequisite
* Xcode 12.0 or higher.
* Cocoapods 1.10.0 or higher.

## Steps to Run
1. Copy `Dozy/ConfigurationDummy.plist` and paste as `Dozy/Configuration.plist`.
2. Replace _Slack Client ID_ and _Slack Client Secret_ values in `Dozy/Configuration.plist` with your relevant Slack credentials.
3. Download or use your own GoogleService-Info.plist file from Firebase and place in root directory (same directory as this README).
4. Perform a `pod install`.
5. Build and run the app.