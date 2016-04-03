module.exports = angular.module 'wordpress-hybrid-client.analytics'
    .config ($WPBMCHSConfig, $analyticsProvider) ->
        if !$WPBMCHSConfig.analytics.enabled or !$WPBMCHSConfig.analytics.trackingId
            return

        if (!IS_PROD)
            $analyticsProvider.developerMode true
        $analyticsProvider.virtualPageviews $WPBMCHSConfig.analytics.virtualPageTracking

    .run ($WPBMCHSConfig) ->
        if !$WPBMCHSConfig.analytics.enabled or !$WPBMCHSConfig.analytics.trackingId
            return

        ((i, s, o, g, r, a, m) ->
            i['GoogleAnalyticsObject'] = r
            i[r] = i[r] or ->
                (i[r].q = i[r].q or []).push arguments
                return
            i[r].l = 1 * new Date
            a = s.createElement(o)
            m = s.getElementsByTagName(o)[0]
            a.async = 1
            a.src = g
            m.parentNode.insertBefore a, m
            return
        ) window, document, 'script', '//www.google-analytics.com/analytics.js', 'ga'

        window.ga 'create', $WPBMCHSConfig.analytics.trackingId, 'auto'
        window.ga 'set', '&uid', $WPBMCHSConfig.analytics.userId
