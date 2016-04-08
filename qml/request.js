function request(url, callback) {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = (function(data) {
        return function() {
            if ( data.readyState == 4 ) {
                console.log('answered:', url)
                try {
                    var js = eval('new Object(' + data.responseText + ')')
                    callback(js)
                } catch (err) {
                    console.log('error:', url, err);
                }
            }
        }
    })(xhr);
    console.log('request:', url)
    xhr.open('GET', url, true);
    xhr.setRequestHeader('accept','application/json')
    xhr.send('');
};
