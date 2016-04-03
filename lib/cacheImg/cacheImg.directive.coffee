module.exports = angular.module 'wpbmchs.cacheImg'
    .directive 'WPBMCHSImgCache', ->
        restrict: 'A'
        link: (scope, el, attrs) ->
            attrs.$observe 'ngSrc', (src) ->
                ImgCache.isCached src, (path, success) ->
                    if success
                        ImgCache.useCachedFile el
                    else
                        ImgCache.cacheFile src, ->
                            ImgCache.useCachedFile el
    .directive 'WPBMCHSImgBackgroundCache', ->
        restrict: 'A'
        link: (scope, el, attrs) ->
            setBackgroundImage = (src) ->
                el.css
                    'background-image': "url('#{src}')"

            attrs.$observe 'WPBMCHSImgBackgroundCache', (src) ->
                ImgCache.isCached src, (path, success) ->
                    if success
                        ImgCache.getCachedFileURL src, (src, srcCached)->
                            setBackgroundImage srcCached
                    else
                        ImgCache.cacheFile src, ->
                        setBackgroundImage src
