# Create namespace
window.WPBMCHS = window.WPBMCHS || {}

require 'ionic-sdk/release/js/ionic.bundle.js'
require './angular-ios9-uiwebview.patch.js'
require 'angular-cache'
require 'angular-moment'
require 'moment'
require './font/font.coffee'
require 'ionic-native-transitions'
require 'expose?_!lodash'
require 'wp-api-angularjs'
require './config.js'
overwriteModule = require '../config/index.js'
customPostsModule = require './customPosts/index.js'
pagesModule = require './pages/index.js'
postsModule = require './posts/index.js'
searchModule = require './search/index.js'
authorsModule = require './authors/index.js'
taxonomiesModule = require './taxonomies/index.js'
filtersModule = require './filters/index.js'
directivesModule = require './directives/index.js'
languageModule = require './language/index.js'
templatesModule = require './templates/index.js'
paramsModule = require './params/index.js'
menuModule = require './menu/index.js'
bookmarkModule = require './bookmark/index.js'
accessibilityModule = require './accessibility/index.js'
loadingModule = require './loading/index.js'
pushNotificationsModule = require './pushNotifications/index.js';

# Style entry point
require './scss/bootstrap'

module.exports = app = angular.module 'wordpress-hybrid-client', [
    'ionic'
    'ngIOS9UIWebViewPatch'
    'wordpress-hybrid-client.config'
    'ionic-native-transitions'
    'ui.router'
    'wp-api-angularjs'
    'angular-cache'
    'angularMoment'
    customPostsModule
    filtersModule
    pagesModule
    taxonomiesModule
    postsModule
    searchModule
    authorsModule
    languageModule
    paramsModule
    menuModule
    bookmarkModule
    accessibilityModule
    loadingModule
    require('./cordova/cordova.module').name
    require('./cacheImg/cacheImg.module').name
    require('./syntaxHighlighter/syntaxHighlighter.module').name
    require('./init/init.module').name
    directivesModule
    templatesModule
    overwriteModule
    pushNotificationsModule
]

app.config ($stateProvider, $urlRouterProvider) ->
    $stateProvider
    .state 'public',
    url: "/public"
    abstract: true
    views:
        '@' :
            template: require "./views/ion-menu.html"
            controller: "WPBMCHSMainController as main"

    $urlRouterProvider.otherwise ($injector, $location) ->
        $WPBMCHSConfig = $injector.get('$WPBMCHSConfig');
        $state = $injector.get('$state');
        $state.go _.get($WPBMCHSConfig, 'menu.defaultState.state'), _.get($WPBMCHSConfig, 'menu.defaultState.params')

###
ANGULAR CONF
###
app.config ($logProvider, $compileProvider) ->
    $logProvider.debugEnabled if IS_PROD then false else true
    $compileProvider.debugInfoEnabled if IS_PROD then false else true

###
NATIVE TRANSITIONS CONF
###
app.config ($WPBMCHSConfig, $ionicNativeTransitionsProvider) ->
    defaultOptions = _.get $WPBMCHSConfig, 'cordova.nativeTransitions.defaultOptions'
    defaultTransition = _.get $WPBMCHSConfig, 'cordova.nativeTransitions.defaultTransition'
    defaultBackTransition = _.get $WPBMCHSConfig, 'cordova.nativeTransitions.defaultBackTransition'
    enabled = _.get $WPBMCHSConfig, 'cordova.nativeTransitions.enabled'
    enabled = if _.isBoolean enabled then enabled else true
    $ionicNativeTransitionsProvider.setDefaultOptions defaultOptions if defaultOptions
    $ionicNativeTransitionsProvider.setDefaultTransition defaultTransition if defaultTransition
    $ionicNativeTransitionsProvider.setDefaultBackTransition defaultBackTransition if defaultBackTransition
    $ionicNativeTransitionsProvider.enable enabled

###
IONIC CONF
###
app.config require('./config/ionic.config.coffee');

###
REST CONF
###
app.config ($WPBMCHSConfig, WpApiProvider, $httpProvider) ->
    WpApiProvider.setDefaultHttpProperties
        timeout: _.get($WPBMCHSConfig, 'api.timeout') || 5000
    WpApiProvider.setBaseUrl _.get($WPBMCHSConfig, 'api.baseUrl') || null
    $httpProvider.defaults.cache = false
    $httpProvider.interceptors.push ($log, $q, $injector, $WPBMCHSConfig) ->
        request: (config) ->
            if _.startsWith config.url, $WPBMCHSConfig.api.baseUrl
                config.headers['Accept-Language'] = $injector.get('$WPBMCHSLanguage').getLocale()
            config || $q.resolve config

###
CACHE CONF
###
app.config ($WPBMCHSConfig, CacheFactoryProvider) ->
    angular.extend(CacheFactoryProvider.defaults, _.get($WPBMCHSConfig, 'cache.data') || {})

###
MEMORY STATS CONF
###
app.config ($WPBMCHSConfig, $compileProvider) ->
    $compileProvider.debugInfoEnabled if IS_PROD then false else true

###
MAIN CONTROLLER
###
app.controller 'WPBMCHSMainController' , ($log, $WPBMCHSConfig) ->
    $log.info 'main controller'

    vm = @
    vm.exposeAsideWhen = _.get($WPBMCHSConfig, 'menu.exposeAsideWhen') || 'large'
    vm.appVersion = wordpressHybridClient.version || null
    vm.appConfig = $WPBMCHSConfig
    vm.appTitle = vm.appConfig.title || null
    vm

###
RUN
###
app.run ($rootScope, $log, $WPBMCHSConfig, $translate, $document, $WPBMCHSLanguage, $ionicPlatform, $WPBMCHSAccessibility, $cordovaSplashscreen, $WPBMCHSInit) ->
    'ngInject';
    $rootScope.appLoaded = undefined
    stateChangeTimeout = null
    # handling debug events
    if !IS_PROD
        $rootScope.$on '$stateNotFound', (event, unfoundState, fromState, fromParams) ->
            $log.info '$stateNotFound', unfoundState
        $rootScope.$on '$stateChangeError', (event, toState, toParams, fromState, fromParams, error) ->
            $log.info '$stateChangeError', error

    $WPBMCHSAccessibility.updateBodyClass()
    
    $rootScope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) ->
        $log.debug 'stateChangeSuccess', toState, toParams, fromState, fromParams
        clearTimeout stateChangeTimeout
        fromStateClass = if fromState.class then _.template(fromState.class)(fromParams) else fromState.name
        toStateClass = if toState.class then _.template(toState.class)(toParams) else toState.name
        stateChangeTimeout = setTimeout () ->
            $document.find('html').removeClass _.kebabCase(fromStateClass)
        , 500
        $document.find('html').addClass _.kebabCase(toStateClass)

    $ionicPlatform.ready () ->
        $WPBMCHSInit.init().finally ()->
            $rootScope.appLoaded = true;
            # For web debug
            if !ionic.Platform.isWebView()
                $translate.use $WPBMCHSLanguage.getLocale()
            else
                $cordovaSplashscreen.hide()

    # Clean up appLoading
    # angular.element(document.querySelector 'html').removeClass 'app-loading'
    # angular.element(document.querySelector '#appLoaderWrapper').remove()
