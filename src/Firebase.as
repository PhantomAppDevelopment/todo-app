package
{
	public class Firebase
	{
		//This will be used as a global variable that holds the logged in user information
		
		public static var LOGGED_USER_DATA:Object;
		
		//Your project API Key
		
		public static const FIREBASE_API_KEY:String = "";
		
		//The url of your project
		
		public static const PROJECT_NAME:String = "";
				
		//These URLs allow user registration and management with Email and Password
		
		private static const AUTH_BASE_URL:String = "https://www.googleapis.com/identitytoolkit/v3/relyingparty/";
		
		public static const EMAIL_PASSWORD_LOGIN:String = AUTH_BASE_URL+"verifyPassword?key="+FIREBASE_API_KEY;
		public static const EMAIL_PASSWORD_SIGNUP:String = AUTH_BASE_URL+"signupNewUser?key="+FIREBASE_API_KEY;
		public static const UPDATE_EMAIL:String = AUTH_BASE_URL+"setAccountInfo?key="+FIREBASE_API_KEY;
		public static const RESET_PASSWORD:String = AUTH_BASE_URL+"getOobConfirmationCode?key="+FIREBASE_API_KEY;
		public static const UPDATE_PASSWORD:String = AUTH_BASE_URL+"setAccountInfo?key="+FIREBASE_API_KEY;
		public static const DELETE_ACCOUNT:String = AUTH_BASE_URL+"deleteAccount?key="+FIREBASE_API_KEY;
					
		//The URLs for different methods, in this case all 4 are the same
		
		public static const FIREBASE_SELECT_URL:String = "https://"+PROJECT_NAME+".firebaseio.com/todos/";
		public static const FIREBASE_INSERT_URL:String = "https://"+PROJECT_NAME+".firebaseio.com/todos/";
		public static const FIREBASE_DELETE_URL:String = "https://"+PROJECT_NAME+".firebaseio.com/todos/";
		public static const FIREBASE_UPDATE_URL:String = "https://"+PROJECT_NAME+".firebaseio.com/todos/";
	}
}