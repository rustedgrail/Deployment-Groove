if(typeof DEPLOYED === 'undefined') {
    var staticUrl;

    var require = function() {
        var rest, path = arguments[0];
        var newScript = document.createElement("script");
        newScript.src = [staticUrl, path].join('/');
        rest = [].slice.call(arguments, 1);
        if (rest.length > 0) {
            newScript.onload = function() { require.apply(null, rest); };
        }

        var oldScript = document.getElementsByTagName("script")[0];
        oldScript.parentNode.insertBefore(newScript, oldScript);
    };
}
