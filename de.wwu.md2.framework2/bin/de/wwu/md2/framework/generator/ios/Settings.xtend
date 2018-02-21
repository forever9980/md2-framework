package de.wwu.md2.framework.generator.ios

/**
 * Various settings to configure the generation process. 
 * According to the "convention over configuration" pattern, defaults are given for all settings. 
 */
class Settings {
	public static final Boolean PRINT_DEBUG_INFO = true
	
	// Used to identify platform content, e.g. for folder structure src-gen/appname.PREFIX
	public static final String PLATFORM_PREFIX = "ios"
	// Path to the static files, relative to platform-specific resources (res/resources/ios/) 
	public static final String STATIC_CODE_PATH = "lib/"
	// Path to the test target files, relative to platform-specific resources (res/resources/ios/)
	public static final String TEST_CODE_PATH = "test/"
	
	// Root folder
	public static String ROOT_FOLDER = "SET_DURING_GENERATION_PROCESS"
	// App name
	public static String APP_NAME = "SET_DURING_GENERATION_PROCESS" 
	
	// Adapt to Xcode user that runs the build process 
	public static final String XCODE_USER_NAME = "christoph"
	// XCode targets
	public static String XCODE_TARGET_TEST = "SET_DURING_GENERATION_PROCESS"
	public static String XCODE_TARGET_APP = "SET_DURING_GENERATION_PROCESS"
	
	// Generator and generation process related constants
	public static final String GENERATOR_VERSION = "1.0"
	public static final String GENERATOR_AUTHOR = "Christoph Rieger"
	public static final String GENERATOR_DATE = "28.09.2015"
	public static final String GENERATION_DATE_FORMAT = "dd.MM.yyyy"
	
	// Paths to platform-specific subfolders
	public static final String MODEL_PATH = "model/"
	public static final String CONTROLLER_PATH = "controller/"
	public static final String VIEW_PATH = "view/"
	public static final String WORKFLOW_PATH = "workflow/"
	
	// Prefixes for the classes to distinguish generated from non-generated classes 
	// and ensure unique naming
	public static final String PREFIX_GLOBAL = "MD2"
	public static final String PREFIX_ENTITY = PREFIX_GLOBAL + "Entity_"
	public static final String PREFIX_ENUM = PREFIX_GLOBAL + "Enum_"
	public static final String PREFIX_CONTENT_PROVIDER = PREFIX_GLOBAL + "CP_"
	public static final String PREFIX_CUSTOM_ACTION = PREFIX_GLOBAL + "CustomAction_"
	
	// Data type related constants
	public static final String DATA_TYPE_DATE_FORMAT = "YYYY-MM-DD"
	public static final String DATA_TYPE_TIME_FORMAT = "hh:mm:ss"
	public static final String DATA_TYPE_DATE_TIME_FORMAT = "YYYY-MM-DD hh:mm:ss"

}