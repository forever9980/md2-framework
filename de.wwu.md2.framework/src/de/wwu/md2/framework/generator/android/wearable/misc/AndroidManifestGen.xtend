package de.wwu.md2.framework.generator.android.wearable.misc

import de.wwu.md2.framework.mD2.App
import de.wwu.md2.framework.mD2.ViewFrame

class AndroidManifestGen {

	// generates android manifest for the project
	// startActivity muss gesetzt werden
	def static String generateProjectAndroidManifest(App app, Iterable<ViewFrame> rootViews, String packageName)'''
		<?xml version="1.0" encoding="utf-8"?>
		<!-- generated in de.wwu.md2.framework.generator.android.wearable.misc.AndroidManifest.generateProjectAndroidManifest() -->
		<manifest xmlns:android="http://schemas.android.com/apk/res/android"
		    package="«packageName»" >

		     <uses-feature android:name="android.hardware.type.watch" />
		     <uses-permission android:name="android.permission.INTERNET" />

		    <application
		        android:name=".«app.name»"
		        android:allowBackup="true"
		        android:icon="@drawable/ic_shopping_cart_white_24dp"
		        android:label="@string/app_name"
		        android:theme="@style/PSWatchapp" >
	        «FOR rv : rootViews»
	        <activity
       			android:name=".«rv.name.toFirstUpper»Activity"
	        	android:label="@string/title_activity_«rv.name.toFirstLower»"
	        	android:launchMode="singleInstance">
        		«IF rv.equals(rootViews.get(0))»
        			<intent-filter>
        				<action android:name="android.intent.action.MAIN" />
	        			<category android:name="android.intent.category.LAUNCHER" />
	        		 </intent-filter>
        		«ENDIF»
	        	</activity>
	        «ENDFOR»
					 </application>
		</manifest>
	'''
}
