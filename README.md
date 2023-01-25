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

(If anyone has a better idea on how to create the .app on MacOS, please don't hesitate to open an issue or a PR)

# *Proof
https://github.com/privacytools/privacytools.io/issues/1789 – Add warning that Signal stores attachments unencrypted and messages unsafely on desktop <br>
https://github.com/signalapp/Signal-Desktop/issues/2815 – All exported data (messages + attachments) are *NOT* encrypted on Disk during (and after) the upgrade process! <br>
https://github.com/signalapp/Signal-Desktop/issues/4042 – encrypted db.sqlite encryptable, hence conversations interceptable <br>
https://github.com/signalapp/Signal-Desktop/issues/5751 – Signal Desktop stores all received attachments unencrypted on filesystem <br>
https://github.com/signalapp/Signal-Desktop/issues/5703 – Desktop app does not support protected storage <br>
https://github.com/signalapp/Signal-Desktop/issues/1017 – Messages are stored in plain text and not encrypted locally <br>
https://github.com/signalapp/Signal-Desktop/issues/452 – Add option to lock the application <br>
https://github.com/signalapp/Signal-Desktop/issues/1318 – What is stored on the pc and where? <br>
https://github.com/signalapp/Signal-Desktop/issues/2793 – The attachments should be encrypted at rest on the drive <br>
[signalusers.org/t/improve-security-of-desktop-apps-encryption-of-data-at-rest](https://community.signalusers.org/t/improve-security-of-desktop-apps-encryption-of-data-at-rest/26494) – 
Improve security of desktop app’s encryption of data at rest <br>
[signalusers.org/t/lock-the-desktop-app-with-a-password](https://community.signalusers.org/t/lock-the-desktop-app-with-a-password/1383) – 
Lock the desktop app with a password <br>
[signalusers.org/t/securety-pin-on-desktop](https://community.signalusers.org/t/securety-pin-on-desktop/17784) – 
Securety PIN on Desktop <br>

