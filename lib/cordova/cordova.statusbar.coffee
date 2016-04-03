module.exports = angular.module 'wordpress-hybrid-client.cordova'
    .run ($log, $WPBMCHSConfig, $cordovaStatusbar, $ionicPlatform) ->
        $log.info 'cordova statusbar'

        $ionicPlatform.ready () ->
            $cordovaStatusbar.styleHex $WPBMCHSConfig.cordova.statubar.color
            if $WPBMCHSConfig.cordova.statubar.show
                $cordovaStatusbar.show()
            else
                $cordovaStatusbar.hide()