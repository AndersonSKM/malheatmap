window._paq = window._paq || [];

// <%# if Rails.configuration.analytics[:enabled] %>
//   <%# url = Rails.configuration.analytics[:url] %>
//   <%# site_id = Rails.configuration.analytics[:site_id] %>

//  (function () {
//    window._paq.push(['trackPageView'])
//    window._paq.push(['enableLinkTracking'])
//    window._paq.push(['setTrackerUrl', '<%= url %>/matomo.php'])
//    window._paq.push(['setSiteId', '<%= site_id %>'])

//    const script = document.createElement('script')
//    const firstScript = document.getElementsByTagName('script')[0]
//    script.type = 'text/javascript'
//    script.id = 'matomo-js'
//    script.async = true
//    script.src = '<%#= url %>/matomo.js'
//    firstScript.parentNode.insertBefore(script, firstScript)

//    let previousPageUrl = null

//    document.addEventListener('turbo:load', function (event) {
//      if (previousPageUrl) {
//        window._paq.push(['setReferrerUrl', previousPageUrl])
//        window._paq.push(['setCustomUrl', window.location.href])
//        window._paq.push(['setDocumentTitle', document.title])
//        if (event.data && event.data.timing) {
//          window._paq.push(['setGenerationTimeMs', event.data.timing.visitEnd - event.data.timing.visitStart])
//        }
//        window._paq.push(['trackPageView'])
//      }
//      previousPageUrl = window.location.href
//    })
//  })()
// <%# end %>
