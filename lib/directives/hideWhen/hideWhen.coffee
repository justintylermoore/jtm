###
@ngdoc directive
@name wordpress - hybrid - client: WPBMCHSHideWhen
@restrict E
@description
Hide an element when a certain media query match
http: //mcgivery.com/ionic-showwhen-directive/
###
module.exports = angular.module('wpbmchs.directives').directive 'WPBMCHSHideWhen', ($window) ->
    restrict: 'A'
    link: ($scope, $element, $attr) ->
        debouncedCheck = ionic.debounce ->
          $scope.$apply ->
            checkExpose()
            return
          return
        , 300, false

        checkExpose = ->
          mq = if $attr.WPBMCHSHideWhen is 'large' then '(min-width:768px)' else $attr.WPBMCHSHideWhen
          if !$window.matchMedia(mq).matches
            $element.removeClass 'ng-hide'
          else
            $element.addClass 'ng-hide'
          return

        onResize = ->
          debouncedCheck()
          return

        checkExpose()
        ionic.on 'resize', onResize, $window
        $scope.$on '$destroy', ->
          ionic.off 'resize', onResize, $window
          return
        return
