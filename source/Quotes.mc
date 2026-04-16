using Toybox.Lang;

class Quote {
    var id as Lang.Number;
    var text as Lang.String;
    var author as Lang.String;

    function initialize(id_ as Lang.Number, t as Lang.String, a as Lang.String) {
        id = id_;
        text = t;
        author = a;
    }
}

module QuoteStore {

    enum {
        BUCKET_MORNING = 0,
        BUCKET_MIDDAY  = 1,
        BUCKET_EVENING = 2,
        BUCKET_NIGHT   = 3
    }

    function bucketForHour(hour as Lang.Number) as Lang.Number {
        if (hour >= 5 and hour < 12)  { return BUCKET_MORNING; }
        if (hour >= 12 and hour < 17) { return BUCKET_MIDDAY; }
        if (hour >= 17 and hour < 21) { return BUCKET_EVENING; }
        return BUCKET_NIGHT;
    }

    function bucketName(b as Lang.Number) as Lang.String {
        if (b == BUCKET_MIDDAY)  { return "midday"; }
        if (b == BUCKET_EVENING) { return "evening"; }
        if (b == BUCKET_NIGHT)   { return "night"; }
        return "morning";
    }

    function pickFresh(bucket as Lang.Number, year as Lang.Number, day as Lang.Number, hour as Lang.Number, recent as Lang.Array<Lang.Number>, settings as Settings) as Quote {
        var pool = _poolFor(bucket);
        var allowed = _filter(pool, settings);
        if (allowed.size() == 0) { allowed = pool; }
        var fresh = _withoutRecent(allowed, recent);
        if (fresh.size() == 0) { fresh = allowed; }
        var idx = (year * 31 + day * 24 + hour) % fresh.size();
        if (idx < 0) { idx = idx + fresh.size(); }
        return fresh[idx];
    }

    function pick(bucket as Lang.Number, year as Lang.Number, day as Lang.Number, hour as Lang.Number) as Quote {
        var pool = _poolFor(bucket);
        var idx = (year * 31 + day * 24 + hour) % pool.size();
        if (idx < 0) { idx = idx + pool.size(); }
        return pool[idx];
    }

    function _poolFor(bucket as Lang.Number) as Lang.Array<Quote> {
        if (bucket == BUCKET_MIDDAY)  { return _midday(); }
        if (bucket == BUCKET_EVENING) { return _evening(); }
        if (bucket == BUCKET_NIGHT)   { return _night(); }
        return _morning();
    }

    function _filter(pool as Lang.Array<Quote>, settings as Settings) as Lang.Array<Quote> {
        var out = [] as Lang.Array<Quote>;
        for (var i = 0; i < pool.size(); i++) {
            if (settings.authorAllowed(pool[i].author)) {
                out.add(pool[i]);
            }
        }
        return out;
    }

    function _withoutRecent(pool as Lang.Array<Quote>, recent as Lang.Array<Lang.Number>) as Lang.Array<Quote> {
        var out = [] as Lang.Array<Quote>;
        for (var i = 0; i < pool.size(); i++) {
            var q = pool[i];
            var seen = false;
            for (var j = 0; j < recent.size(); j++) {
                if (recent[j] == q.id) { seen = true; break; }
            }
            if (!seen) { out.add(q); }
        }
        return out;
    }

    function _morning() as Lang.Array<Quote> {
        return [
            new Quote(101, "The impediment to action advances action. What stands in the way becomes the way.", "Marcus Aurelius"),
            new Quote(102, "At dawn, when you have trouble getting out of bed, tell yourself: I have to go to work as a human being.", "Marcus Aurelius"),
            new Quote(103, "Begin the morning by saying to yourself: I shall meet with the busybody, the ungrateful, the arrogant; not one of them can hurt me.", "Marcus Aurelius"),
            new Quote(104, "First say to yourself what you would be; then do what you have to do.", "Epictetus"),
            new Quote(105, "Begin at once to live, and count each separate day as a separate life.", "Seneca"),
            new Quote(106, "It is not the man who has too little, but the man who craves more, that is poor.", "Seneca"),
            new Quote(107, "Before anything else, look to see what is required, then begin.", "Epictetus"),
            new Quote(108, "Each day provides its own gifts.", "Marcus Aurelius"),
            new Quote(109, "Look well into thyself; there is a source of strength which will always spring up if thou wilt always look.", "Marcus Aurelius"),
            new Quote(110, "Do not despise death, but be well content with it, since this too is one of those things which nature wills.", "Marcus Aurelius"),
            new Quote(111, "Today I escaped anxiety. Or no, I discarded it, because it was within me, in my own perceptions.", "Marcus Aurelius"),
            new Quote(112, "What is your vocation? To be a good person.", "Marcus Aurelius"),
            new Quote(113, "Difficulties show a person's character. So when a hard task comes, remember God is matching you with a rough youth.", "Epictetus"),
            new Quote(114, "He who laughs at himself never runs out of things to laugh at.", "Epictetus"),
            new Quote(115, "Don't seek for everything to happen as you wish, but rather wish that everything happens as it actually does.", "Epictetus"),
            new Quote(116, "All cruelty springs from weakness.", "Seneca"),
            new Quote(117, "Sometimes even to live is an act of courage.", "Seneca"),
            new Quote(118, "While we wait for life, life passes.", "Seneca"),
            new Quote(119, "He who is brave is free.", "Seneca"),
            new Quote(120, "If you wish to improve, be content to appear clueless or stupid in extraneous matters.", "Epictetus"),
            new Quote(121, "Waste no more time arguing what a good man should be. Be one.", "Marcus Aurelius"),
            new Quote(122, "Receive without conceit, release without struggle.", "Marcus Aurelius"),
            new Quote(123, "Let opinion be taken away, and no man will think himself wronged.", "Marcus Aurelius"),
            new Quote(124, "Always run on the short way; and the short way is the natural one.", "Marcus Aurelius"),
            new Quote(125, "Step over the obstacle. The obstacle is the way.", "Marcus Aurelius"),
            new Quote(126, "Wherever there is a human being, there is an opportunity for a kindness.", "Seneca"),
            new Quote(127, "Throw away your books; stop letting yourself be distracted.", "Marcus Aurelius"),
            new Quote(128, "What is morning? It is the smallest start, repeated.", "Seneca"),
            new Quote(129, "Cease, then, walking thither and back; for thou hast not long to live.", "Marcus Aurelius"),
            new Quote(130, "Awake from sleep and recognise that they were dreams that troubled you.", "Marcus Aurelius")
        ] as Lang.Array<Quote>;
    }

    function _midday() as Lang.Array<Quote> {
        return [
            new Quote(201, "You have power over your mind, not outside events. Realize this, and you will find strength.", "Marcus Aurelius"),
            new Quote(202, "No man is free who is not master of himself.", "Epictetus"),
            new Quote(203, "Wealth consists not in having great possessions, but in having few wants.", "Epictetus"),
            new Quote(204, "Difficulties strengthen the mind, as labor does the body.", "Seneca"),
            new Quote(205, "The best revenge is to be unlike him who performed the injury.", "Marcus Aurelius"),
            new Quote(206, "It is the power of the mind to be unconquerable.", "Seneca"),
            new Quote(207, "Whatever can happen at any time can happen today.", "Seneca"),
            new Quote(208, "Confine yourself to the present.", "Marcus Aurelius"),
            new Quote(209, "The happiness of your life depends upon the quality of your thoughts.", "Marcus Aurelius"),
            new Quote(210, "Concentrate every minute on doing what is in front of you with precise and genuine seriousness.", "Marcus Aurelius"),
            new Quote(211, "Don't go expecting Plato's Republic; be satisfied with even the slightest progress.", "Marcus Aurelius"),
            new Quote(212, "When you arise in the morning think of what a privilege it is to be alive, to think, to enjoy, to love.", "Marcus Aurelius"),
            new Quote(213, "First learn the meaning of what you say, and then speak.", "Epictetus"),
            new Quote(214, "Know, first, who you are, and then adorn yourself accordingly.", "Epictetus"),
            new Quote(215, "Practice yourself, for heaven's sake, in little things; and then proceed to greater.", "Epictetus"),
            new Quote(216, "Other people's views and troubles can be contagious. Don't sabotage yourself by unwittingly adopting negative, unproductive attitudes.", "Epictetus"),
            new Quote(217, "I judge you unfortunate because you have never lived through misfortune.", "Seneca"),
            new Quote(218, "We suffer more often in imagination than in reality.", "Seneca"),
            new Quote(219, "Luck is what happens when preparation meets opportunity.", "Seneca"),
            new Quote(220, "It does not matter what you bear, but how you bear it.", "Seneca"),
            new Quote(221, "Whoever does not regard what he has as most ample wealth, is unhappy, though he be master of the world.", "Seneca"),
            new Quote(222, "Don't demand or expect that events happen as you would wish them to.", "Epictetus"),
            new Quote(223, "If you would be a reader, read; if a writer, write.", "Epictetus"),
            new Quote(224, "The whole future lies in uncertainty: live immediately.", "Seneca"),
            new Quote(225, "A gem cannot be polished without friction, nor a man perfected without trials.", "Seneca"),
            new Quote(226, "He suffers more than necessary, who suffers before it is necessary.", "Seneca"),
            new Quote(227, "Anger, if not restrained, is frequently more hurtful to us than the injury that provokes it.", "Seneca"),
            new Quote(228, "The greatest remedy for anger is delay.", "Seneca"),
            new Quote(229, "Throw out your conceited opinions, for it is impossible for a person to begin to learn what he thinks he already knows.", "Epictetus"),
            new Quote(230, "Hang on to your youthful enthusiasms — you'll be able to use them better when you're older.", "Seneca")
        ] as Lang.Array<Quote>;
    }

    function _evening() as Lang.Array<Quote> {
        return [
            new Quote(301, "How much trouble he avoids who does not look to see what his neighbor says or does.", "Marcus Aurelius"),
            new Quote(302, "It is not what happens to you, but how you react to it that matters.", "Epictetus"),
            new Quote(303, "Every new beginning comes from some other beginning's end.", "Seneca"),
            new Quote(304, "As is a tale, so is life: not how long it is, but how good it is, is what matters.", "Seneca"),
            new Quote(305, "When another blames you or hates you, or people voice similar criticisms, go to their souls, penetrate inside, and see what sort of people they are.", "Marcus Aurelius"),
            new Quote(306, "Look back over the past, and reflect how many changes of regimes have come and gone.", "Marcus Aurelius"),
            new Quote(307, "Let not your mind run on what you lack as much as on what you have already.", "Marcus Aurelius"),
            new Quote(308, "He has the most who is most content with the least.", "Diogenes"),
            new Quote(309, "If anyone tells you that a certain person speaks ill of you, do not make excuses.", "Epictetus"),
            new Quote(310, "Caretake this moment. Immerse yourself in its particulars.", "Epictetus"),
            new Quote(311, "Make the best use of what is in your power, and take the rest as it happens.", "Epictetus"),
            new Quote(312, "We are more often frightened than hurt; and we suffer more in imagination than reality.", "Seneca"),
            new Quote(313, "True happiness is to enjoy the present, without anxious dependence upon the future.", "Seneca"),
            new Quote(314, "Just that you do the right thing. The rest doesn't matter.", "Marcus Aurelius"),
            new Quote(315, "The soul becomes dyed with the colour of its thoughts.", "Marcus Aurelius"),
            new Quote(316, "If it is not right, do not do it; if it is not true, do not say it.", "Marcus Aurelius"),
            new Quote(317, "It never ceases to amaze me: we all love ourselves more than other people, but care more about their opinion than our own.", "Marcus Aurelius"),
            new Quote(318, "Receive without pride, let go without attachment.", "Marcus Aurelius"),
            new Quote(319, "If you are distressed by anything external, the pain is not due to the thing itself, but to your own estimate of it.", "Marcus Aurelius"),
            new Quote(320, "Death smiles at us all; all we can do is smile back.", "Marcus Aurelius"),
            new Quote(321, "Time is a sort of river of passing events, and strong is its current.", "Marcus Aurelius"),
            new Quote(322, "He who lives in harmony with himself lives in harmony with the universe.", "Marcus Aurelius"),
            new Quote(323, "First learn to be silent. Let your quiet mind listen and absorb.", "Pythagoras"),
            new Quote(324, "Reject your sense of injury and the injury itself disappears.", "Marcus Aurelius"),
            new Quote(325, "Look at every day as if it were the last; the day will come when you will not have time even to draw breath.", "Marcus Aurelius"),
            new Quote(326, "All things fade away and become legend, and legend itself is soon swallowed up in oblivion.", "Marcus Aurelius"),
            new Quote(327, "If thou are pained by any external thing, it is not this thing that disturbs thee, but thy own judgment about it.", "Marcus Aurelius"),
            new Quote(328, "What we cannot bear removes us from life; what remains can be borne.", "Seneca"),
            new Quote(329, "All that we hear is an opinion, not a fact. All that we see is a perspective, not the truth.", "Marcus Aurelius"),
            new Quote(330, "It is the time of your life to be at peace with the world and with yourself.", "Seneca")
        ] as Lang.Array<Quote>;
    }

    function _night() as Lang.Array<Quote> {
        return [
            new Quote(401, "We suffer more in imagination than in reality.", "Seneca"),
            new Quote(402, "Sleep is the best meditation.", "Seneca"),
            new Quote(403, "Do not explain your philosophy. Embody it.", "Epictetus"),
            new Quote(404, "He who fears death will never do anything worthy of a living man.", "Seneca"),
            new Quote(405, "Confine yourself to the present.", "Marcus Aurelius"),
            new Quote(406, "If thou workest at that which is before thee, thou wilt live happy.", "Marcus Aurelius"),
            new Quote(407, "Nothing happens to anyone that he can't endure.", "Marcus Aurelius"),
            new Quote(408, "When you arise in the morning, think of what a precious privilege it is to be alive.", "Marcus Aurelius"),
            new Quote(409, "Death is a release from the impressions of the senses.", "Marcus Aurelius"),
            new Quote(410, "Whatever happens at all happens as it should.", "Marcus Aurelius"),
            new Quote(411, "Accept the things to which fate binds you, and love the people with whom fate brings you together.", "Marcus Aurelius"),
            new Quote(412, "Loss is nothing else but change, and change is Nature's delight.", "Marcus Aurelius"),
            new Quote(413, "Disturbance comes only from within: from our own perceptions.", "Marcus Aurelius"),
            new Quote(414, "Do every act as if it were thy last.", "Marcus Aurelius"),
            new Quote(415, "It is not death that a man should fear, but he should fear never beginning to live.", "Marcus Aurelius"),
            new Quote(416, "Tomorrow is nothing, today is too late; the good lived yesterday.", "Marcus Aurelius"),
            new Quote(417, "If anyone can show me, and prove to me, that I am wrong in thought or deed, I will gladly change.", "Marcus Aurelius"),
            new Quote(418, "All that exists is the seed of what shall come from it.", "Marcus Aurelius"),
            new Quote(419, "Whenever you are about to find fault with someone, ask yourself the following question: What fault of mine most nearly resembles the one I am about to criticize?", "Marcus Aurelius"),
            new Quote(420, "He who has a why to live can bear almost any how.", "Seneca"),
            new Quote(421, "All cruelty springs from weakness.", "Seneca"),
            new Quote(422, "Begin to be now what you will be hereafter.", "Jerome"),
            new Quote(423, "There is nothing happens to any person but what was in his power to go through with.", "Marcus Aurelius"),
            new Quote(424, "It is in our power to have no opinion about a thing and not to be disturbed in our soul.", "Marcus Aurelius"),
            new Quote(425, "If you are pained by any external thing, it is not this thing that disturbs you, but your own judgment about it.", "Marcus Aurelius"),
            new Quote(426, "Stop wandering about! You aren't likely to read your own notebooks, or ancient histories, or the anthologies you've collected to enjoy in your old age.", "Marcus Aurelius"),
            new Quote(427, "Death and life, success and failure, pain and pleasure, honor and dishonor, all these things equally happen to good men and bad.", "Marcus Aurelius"),
            new Quote(428, "I have often wondered how it is that every man loves himself more than all the rest of men, but yet sets less value on his own opinion of himself than on the opinion of others.", "Marcus Aurelius"),
            new Quote(429, "Where you do not wish to go, do not be carried; where you do wish to go, walk steadily.", "Epictetus"),
            new Quote(430, "Sleep is the half-brother of Death.", "Hesiod")
        ] as Lang.Array<Quote>;
    }
}
