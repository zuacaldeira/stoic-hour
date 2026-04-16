using Toybox.Application.Properties;
using Toybox.Lang;

class Settings {
    var use24Hour as Lang.Boolean;
    var fontSize as Lang.Number;
    var includeMarcus as Lang.Boolean;
    var includeEpictetus as Lang.Boolean;
    var includeSeneca as Lang.Boolean;

    function initialize(use24Hour_ as Lang.Boolean, fontSize_ as Lang.Number, m as Lang.Boolean, e as Lang.Boolean, s as Lang.Boolean) {
        use24Hour = use24Hour_;
        fontSize = fontSize_;
        includeMarcus = m;
        includeEpictetus = e;
        includeSeneca = s;
        if (!includeMarcus and !includeEpictetus and !includeSeneca) {
            includeMarcus = true;
            includeEpictetus = true;
            includeSeneca = true;
        }
    }

    static function load() as Settings {
        var u = _readBool("use24Hour", true);
        var f = _readNumber("fontSize", 2);
        if (f < 1) { f = 1; }
        if (f > 3) { f = 3; }
        var m = _readBool("includeMarcus", true);
        var e = _readBool("includeEpictetus", true);
        var s = _readBool("includeSeneca", true);
        return new Settings(u, f, m, e, s);
    }

    function authorAllowed(author as Lang.String) as Lang.Boolean {
        if (author.equals("Marcus Aurelius")) { return includeMarcus; }
        if (author.equals("Epictetus"))       { return includeEpictetus; }
        if (author.equals("Seneca"))          { return includeSeneca; }
        return true;
    }

    private static function _readBool(key as Lang.String, def as Lang.Boolean) as Lang.Boolean {
        var raw = Properties.getValue(key);
        if (raw instanceof Lang.Boolean) { return raw as Lang.Boolean; }
        return def;
    }

    private static function _readNumber(key as Lang.String, def as Lang.Number) as Lang.Number {
        var raw = Properties.getValue(key);
        if (raw instanceof Lang.Number) { return raw as Lang.Number; }
        return def;
    }
}
