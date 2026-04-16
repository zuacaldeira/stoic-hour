using Toybox.Test;
using Toybox.Lang;

(:test)
function testBucketBoundaries(logger as Test.Logger) as Lang.Boolean {
    Test.assertEqualMessage(QuoteStore.bucketForHour(5),  QuoteStore.BUCKET_MORNING, "5h is morning");
    Test.assertEqualMessage(QuoteStore.bucketForHour(11), QuoteStore.BUCKET_MORNING, "11h is morning");
    Test.assertEqualMessage(QuoteStore.bucketForHour(12), QuoteStore.BUCKET_MIDDAY,  "12h is midday");
    Test.assertEqualMessage(QuoteStore.bucketForHour(16), QuoteStore.BUCKET_MIDDAY,  "16h is midday");
    Test.assertEqualMessage(QuoteStore.bucketForHour(17), QuoteStore.BUCKET_EVENING, "17h is evening");
    Test.assertEqualMessage(QuoteStore.bucketForHour(20), QuoteStore.BUCKET_EVENING, "20h is evening");
    Test.assertEqualMessage(QuoteStore.bucketForHour(21), QuoteStore.BUCKET_NIGHT,   "21h is night");
    Test.assertEqualMessage(QuoteStore.bucketForHour(0),  QuoteStore.BUCKET_NIGHT,   "0h is night");
    Test.assertEqualMessage(QuoteStore.bucketForHour(4),  QuoteStore.BUCKET_NIGHT,   "4h is night");
    return true;
}

(:test)
function testPickIsDeterministic(logger as Test.Logger) as Lang.Boolean {
    var q1 = QuoteStore.pick(QuoteStore.BUCKET_MORNING, 2026, 100, 7);
    var q2 = QuoteStore.pick(QuoteStore.BUCKET_MORNING, 2026, 100, 7);
    Test.assertEqualMessage(q1.id, q2.id, "same inputs return same quote");
    return true;
}

(:test)
function testPickVariesByHour(logger as Test.Logger) as Lang.Boolean {
    var unique = {} as Lang.Dictionary<Lang.Number, Lang.Boolean>;
    for (var h = 5; h < 12; h++) {
        var q = QuoteStore.pick(QuoteStore.BUCKET_MORNING, 2026, 100, h);
        unique.put(q.id, true);
    }
    Test.assertMessage(unique.size() >= 5, "morning bucket rotates through ≥5 quotes across the day");
    return true;
}

(:test)
function testPickFreshAvoidsRecent(logger as Test.Logger) as Lang.Boolean {
    var settings = new Settings(true, 2, true, true, true);
    var first = QuoteStore.pickFresh(QuoteStore.BUCKET_MORNING, 2026, 100, 7, [] as Lang.Array<Lang.Number>, settings);
    var recent = [first.id] as Lang.Array<Lang.Number>;
    var second = QuoteStore.pickFresh(QuoteStore.BUCKET_MORNING, 2026, 100, 7, recent, settings);
    Test.assertNotEqualMessage(first.id, second.id, "pickFresh excludes recent quotes");
    return true;
}

(:test)
function testAuthorFilter(logger as Test.Logger) as Lang.Boolean {
    var marcusOnly = new Settings(true, 2, true, false, false);
    var q = QuoteStore.pickFresh(QuoteStore.BUCKET_MIDDAY, 2026, 100, 13, [] as Lang.Array<Lang.Number>, marcusOnly);
    Test.assertEqualMessage(q.author, "Marcus Aurelius", "Marcus-only filter selects Marcus");
    return true;
}

(:test)
function testEmptyAuthorFilterFallsBack(logger as Test.Logger) as Lang.Boolean {
    var noneEnabled = new Settings(true, 2, false, false, false);
    Test.assertMessage(noneEnabled.includeMarcus, "empty filter resets to all-on");
    Test.assertMessage(noneEnabled.includeEpictetus, "empty filter resets to all-on");
    Test.assertMessage(noneEnabled.includeSeneca, "empty filter resets to all-on");
    return true;
}

(:test)
function testAllPoolsHaveQuotes(logger as Test.Logger) as Lang.Boolean {
    Test.assertMessage(QuoteStore._morning().size()  >= 25, "morning pool ≥25");
    Test.assertMessage(QuoteStore._midday().size()   >= 25, "midday pool ≥25");
    Test.assertMessage(QuoteStore._evening().size()  >= 25, "evening pool ≥25");
    Test.assertMessage(QuoteStore._night().size()    >= 25, "night pool ≥25");
    return true;
}
