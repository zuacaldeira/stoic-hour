using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Application;
using Toybox.Application.Properties;
using Toybox.Application.Storage;
using Toybox.Lang;

class StoicHourView extends WatchUi.WatchFace {

    private const RECENT_KEY as Lang.String = "recentQuotes";
    private const RECENT_MAX as Lang.Number = 8;

    private var _currentQuote as Quote?;
    private var _currentHour as Lang.Number;
    private var _isAsleep as Lang.Boolean;
    private var _wrapCacheKey as Lang.String?;
    private var _wrapCacheLines as Lang.Array<Lang.String>?;
    private var _wrapCacheFont as Graphics.FontDefinition?;
    private var _settings as Settings;

    function initialize() {
        WatchFace.initialize();
        _currentQuote = null;
        _currentHour = -1;
        _isAsleep = false;
        _wrapCacheKey = null;
        _wrapCacheLines = null;
        _wrapCacheFont = null;
        _settings = Settings.load();
    }

    function onLayout(dc as Graphics.Dc) as Void {}

    function onShow() as Void {}

    function onHide() as Void {}

    function onSettingsChanged() as Void {
        _settings = Settings.load();
        _invalidateCache();
        _currentQuote = null;
        _currentHour = -1;
        WatchUi.requestUpdate();
    }

    function onExitSleep() as Void {
        _isAsleep = false;
        WatchUi.requestUpdate();
    }

    function onEnterSleep() as Void {
        _isAsleep = true;
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var clockTime = System.getClockTime();
        var hour = clockTime.hour;
        var minute = clockTime.min;
        var bucket = QuoteStore.bucketForHour(hour);

        if (_currentQuote == null or hour != _currentHour) {
            _currentHour = hour;
            var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
            var recent = _loadRecent();
            _currentQuote = QuoteStore.pickFresh(bucket, today.year, today.day, hour, recent, _settings);
            _rememberQuote(_currentQuote);
            _invalidateCache();
        }

        var w = dc.getWidth();
        var h = dc.getHeight();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        _drawTime(dc, hour, minute, w, h);
        _drawAccentLine(dc, w, h);

        if (_currentQuote != null and !_isAsleep) {
            var timeFontH = dc.getFontHeight(Graphics.FONT_NUMBER_MEDIUM);
            var quoteZoneTop = (h*22/100) + (timeFontH / 2) + 6;
            var quoteZoneBot = h*76/100;
            _drawWrappedQuote(dc, _currentQuote.text as Lang.String, _currentQuote.author as Lang.String, w, h, quoteZoneTop, quoteZoneBot);
        }
    }

    function onPartialUpdate(dc as Graphics.Dc) as Void {
        if (!_isAsleep) { return; }
        var clockTime = System.getClockTime();
        _drawTime(dc, clockTime.hour, clockTime.min, dc.getWidth(), dc.getHeight());
    }

    private function _drawTime(dc as Graphics.Dc, hour as Lang.Number, minute as Lang.Number, w as Lang.Number, h as Lang.Number) as Void {
        var displayHour = hour;
        var suffix = "";
        if (!_settings.use24Hour) {
            if (hour == 0) { displayHour = 12; suffix = "a"; }
            else if (hour < 12) { suffix = "a"; }
            else if (hour == 12) { suffix = "p"; }
            else { displayHour = hour - 12; suffix = "p"; }
        }
        var timeStr = Lang.format("$1$:$2$", [displayHour.format("%02d"), minute.format("%02d")]);
        var timeColor = _isAsleep ? Graphics.COLOR_DK_GRAY : Graphics.COLOR_WHITE;
        dc.setColor(timeColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w/2, h*22/100, Graphics.FONT_NUMBER_MEDIUM, timeStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        if (suffix.length() > 0 and !_isAsleep) {
            var timeWidth = dc.getTextWidthInPixels(timeStr, Graphics.FONT_NUMBER_MEDIUM);
            var sx = (w/2) + (timeWidth/2) + 4;
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(sx, h*22/100, Graphics.FONT_XTINY, suffix, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    private function _drawAccentLine(dc as Graphics.Dc, w as Lang.Number, h as Lang.Number) as Void {
        if (_isAsleep) { return; }
        var y = h*32/100;
        var lineW = w*22/100;
        var x1 = (w/2) - (lineW/2);
        var x2 = (w/2) + (lineW/2);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawLine(x1, y, x2, y);
    }

    private function _drawWrappedQuote(dc as Graphics.Dc, text as Lang.String, author as Lang.String, w as Lang.Number, h as Lang.Number, zoneTop as Lang.Number, zoneBot as Lang.Number) as Void {
        var maxLineWidth = (w * 78) / 100;
        var zoneHeight = zoneBot - zoneTop;
        var key = text + "|" + maxLineWidth + "|" + zoneHeight + "|" + _settings.fontSize;

        var lines;
        var chosenFont;
        if (_wrapCacheKey != null and _wrapCacheKey.equals(key) and _wrapCacheLines != null and _wrapCacheFont != null) {
            lines = _wrapCacheLines;
            chosenFont = _wrapCacheFont;
        } else {
            var fonts;
            if (_settings.fontSize == 1) {
                fonts = [Graphics.FONT_TINY, Graphics.FONT_XTINY] as Lang.Array<Graphics.FontDefinition>;
            } else if (_settings.fontSize == 2) {
                fonts = [Graphics.FONT_SMALL, Graphics.FONT_TINY, Graphics.FONT_XTINY] as Lang.Array<Graphics.FontDefinition>;
            } else {
                fonts = [Graphics.FONT_MEDIUM, Graphics.FONT_SMALL, Graphics.FONT_TINY, Graphics.FONT_XTINY] as Lang.Array<Graphics.FontDefinition>;
            }
            chosenFont = fonts[fonts.size() - 1];
            lines = null;
            for (var f = 0; f < fonts.size(); f++) {
                var font = fonts[f];
                var lh = dc.getFontHeight(font);
                var attempt = _wrapText(dc, text, font, maxLineWidth);
                if (attempt.size() * lh <= zoneHeight) {
                    chosenFont = font;
                    lines = attempt;
                    break;
                }
                chosenFont = font;
                lines = attempt;
            }
            var lineHeight = dc.getFontHeight(chosenFont);
            var maxLines = zoneHeight / lineHeight;
            if (maxLines < 1) { maxLines = 1; }
            if (lines != null and lines.size() > maxLines) {
                var truncated = [] as Lang.Array<Lang.String>;
                for (var i = 0; i < maxLines - 1; i++) {
                    truncated.add(lines[i]);
                }
                truncated.add(lines[maxLines - 1] + "...");
                lines = truncated;
            }
            _wrapCacheKey = key;
            _wrapCacheLines = lines;
            _wrapCacheFont = chosenFont;
        }

        if (lines == null) { return; }

        var lh = dc.getFontHeight(chosenFont);
        var totalH = lines.size() * lh;
        var startY = zoneTop + (zoneHeight - totalH) / 2;

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < lines.size(); i++) {
            dc.drawText(w/2, startY + i*lh, chosenFont, lines[i], Graphics.TEXT_JUSTIFY_CENTER);
        }

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w/2, h*82/100, Graphics.FONT_XTINY, "— " + author, Graphics.TEXT_JUSTIFY_CENTER);
    }

    private function _wrapText(dc as Graphics.Dc, text as Lang.String, font as Graphics.FontDefinition, maxWidth as Lang.Number) as Lang.Array<Lang.String> {
        var words = _splitWords(text);
        var lines = [] as Lang.Array<Lang.String>;
        var current = "";
        for (var i = 0; i < words.size(); i++) {
            var word = words[i];
            var trial = current.length() == 0 ? word : current + " " + word;
            var trialWidth = dc.getTextWidthInPixels(trial, font);
            if (trialWidth <= maxWidth) {
                current = trial;
            } else {
                if (current.length() > 0) {
                    lines.add(current);
                }
                if (dc.getTextWidthInPixels(word, font) > maxWidth) {
                    var pieces = _hardBreakWord(dc, word, font, maxWidth);
                    for (var p = 0; p < pieces.size() - 1; p++) {
                        lines.add(pieces[p]);
                    }
                    current = pieces[pieces.size() - 1];
                } else {
                    current = word;
                }
            }
        }
        if (current.length() > 0) {
            lines.add(current);
        }
        return lines;
    }

    private function _hardBreakWord(dc as Graphics.Dc, word as Lang.String, font as Graphics.FontDefinition, maxWidth as Lang.Number) as Lang.Array<Lang.String> {
        var pieces = [] as Lang.Array<Lang.String>;
        var start = 0;
        var len = word.length();
        while (start < len) {
            var end = len;
            while (end > start) {
                var slice = word.substring(start, end);
                if (dc.getTextWidthInPixels(slice, font) <= maxWidth) {
                    pieces.add(slice);
                    break;
                }
                end -= 1;
            }
            if (end <= start) { end = start + 1; pieces.add(word.substring(start, end)); }
            start = end;
        }
        return pieces;
    }

    private function _splitWords(text as Lang.String) as Lang.Array<Lang.String> {
        var words = [] as Lang.Array<Lang.String>;
        var len = text.length();
        var start = 0;
        for (var i = 0; i <= len; i++) {
            var atSpace = (i == len) or text.substring(i, i+1).equals(" ");
            if (atSpace) {
                if (i > start) {
                    words.add(text.substring(start, i));
                }
                start = i + 1;
            }
        }
        return words;
    }

    private function _invalidateCache() as Void {
        _wrapCacheKey = null;
        _wrapCacheLines = null;
        _wrapCacheFont = null;
    }

    private function _loadRecent() as Lang.Array<Lang.Number> {
        var raw = Storage.getValue(RECENT_KEY);
        if (raw instanceof Lang.Array) {
            return raw as Lang.Array<Lang.Number>;
        }
        return [] as Lang.Array<Lang.Number>;
    }

    private function _rememberQuote(q as Quote?) as Void {
        if (q == null) { return; }
        var recent = _loadRecent();
        recent.add(q.id);
        while (recent.size() > RECENT_MAX) {
            recent = recent.slice(1, recent.size());
        }
        Storage.setValue(RECENT_KEY, recent);
    }
}
