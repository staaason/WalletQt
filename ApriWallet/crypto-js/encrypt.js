Qt.include("./crypto-js.js");
const iv = "JNwr7WXEQ8Nurauw";
    function encryptAES(content, key) {
            var CryptoJS = CryptoJSLib.CryptoJS;
            var AES = CryptoJS.AES;
            var ivStr  = CryptoJS.enc.Utf8.parse(iv);
            var keyStr = CryptoJS.enc.Utf8.parse(key);

            var text = AES.encrypt(content, keyStr, {
                                       iv: ivStr,
                                       mode: CryptoJS.mode.CBC,
                                       padding: CryptoJS.pad.Pkcs7
                                   });
            return text.toString();
        }
