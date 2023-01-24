# Signal Desktop Encrypter

#### _(Since the Signal Desktop devs clearly won't [listen to its users](#proof)\*, we're stuck doing hacky shit like this...)_

This script provides you with the missing local storage-encryption feature in Signal Desktop using VeraCrypt.

It basically just creates an encrypted volume, moves your Signal data to it, symlinks the original data dir to the encrypted volume and creates a laucher that will prompt you for your password, unlock the volume, run Signal and unmount the volume again as soon as Signal exits.

Then just run the launcher instead of Signal and pretend the password prompt is a Signal feature.<br>
It's kinda hacky but it works pretty well.

Tested on Debian 11 and MacOS 12.5.

**NOTE:** (For MacOS) - There's a binary blob in launcher.tar.gz. It's an 'Automator Application Stub' used to run an Automator workflow as a MacOS app (for the launcher).
If you're paranoid (which you should be), you can make your own or just compare it to this binary:

1. Open Automator
2. New -> Application
3. (leave it blank)
4. Save the .app
5. Binary is located at "theappyoujustsaved.app/Contents/MacOS/Automator Application Stub"

Feel free to open an issue if you're having trouble.


# Proof
https://github.com/privacytools/privacytools.io/issues/1789
https://github.com/signalapp/Signal-Desktop/issues/2815
https://github.com/signalapp/Signal-Desktop/issues/4042
https://github.com/signalapp/Signal-Desktop/issues/5751
https://github.com/signalapp/Signal-Desktop/issues/5703
https://github.com/signalapp/Signal-Desktop/issues/1017
https://github.com/signalapp/Signal-Desktop/issues/452
https://github.com/signalapp/Signal-Desktop/issues/1318
https://github.com/signalapp/Signal-Desktop/issues/2793
https://community.signalusers.org/t/improve-security-of-desktop-apps-encryption-of-data-at-rest/26494
https://community.signalusers.org/t/lock-the-desktop-app-with-a-password/1383
https://community.signalusers.org/t/securety-pin-on-desktop/17784

