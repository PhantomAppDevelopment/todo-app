package utils
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class ProfileManager
	{
		private static const file:File = File.applicationStorageDirectory.resolvePath("profile.data");
		private static var fileStream:FileStream;

		/**
		 * Saves the data from a logged in user
		 *
		 * @param profile An Object containing profile information from Firebase.
		 */
		public static function saveProfile(profile:Object):void
		{
			fileStream = new FileStream();
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeObject(profile);
			fileStream.close();
		}

		/**
		 * Loads the user data from the profile.data file into an object.
		 */
		public static function loadProfile():Object
		{
			var myObject:Object = new Object();

			if (file.exists) {
				fileStream = new FileStream();
				fileStream.open(file, FileMode.READ);
				myObject = fileStream.readObject();
				fileStream.close();
			} else {
				myObject = {};
			}

			return myObject;
		}

		/**
		 * Checks if the user is logged in
		 */
		public static function isLoggedIn():Boolean
		{
			var tempObject:Object = loadProfile();

			//We check if the profile exists by checking the existense of the localId value

			if (tempObject.user_id == null) {
				tempObject = null;
				return false;
			} else {
				tempObject = null;
				return true;
			}
		}

		/**
		 * Sign outs the user from the app by setting the profile.data file into an empty object.
		 */
		public static function signOut():void
		{
			fileStream = new FileStream();
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeObject({});
			fileStream.close();
		}

	}
}