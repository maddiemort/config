final: prev: {
  iosevka-custom = prev.iosevka.override {
    set = "Custom";
    privateBuildPlan = ''
      [buildPlans.IosevkaCustom]
      family = "Iosevka Custom"
      spacing = "term"
      serifs = "sans"
      noCvSs = true
      exportGlyphNames = false

      [buildPlans.IosevkaCustom.variants]
      inherits = "ss15"

      [buildPlans.IosevkaCustom.variants.design]
      digit-form = "old-style"
      capital-g = "toothless-corner-inward-serifed-hooked"
      capital-p = "open-serifless"
      capital-q = "open-swash"
      capital-r = "straight-open-serifless"
      capital-v = "curly-serifless"
      capital-w = "curly-serifless"
      capital-x = "curly-serifless"
      capital-y = "curly-serifless"
      capital-z = "curly-serifless"
      i = "serifed-asymmetric"
      q = "tailed-serifless"
      r = "serifed"
      u = "toothed-bottom-right-serifed"
      v = "curly-serifless"
      w = "curly-serifless"
      x = "semi-chancery-curly-serifless"
      y = "curly-serifless"
      z = "curly-serifless"
      lower-eth = "straight-bar"
      two = "curly-neck-serifless"
      three = "flat-top-serifless"
      four = "semi-open-non-crossing-serifless"
      seven = "bend-serifed-crossbar"
      underscore = "high"
      guillemet = "curly"
      number-sign = "upright-open"
      ampersand = "flat-top"
      dollar = "interrupted"
      percent = "rings-continuous-slash-also-connected"
      ascii-single-quote = "straight"
      question = "smooth"
      cent = "bar-interrupted"
      lig-ltgteq = "flat"
      lig-neq = "vertical-dotted"
      lig-equal-chain = "without-notch"
      lig-hyphen-chain = "with-notch"

      [buildPlans.IosevkaCustom.variants.italic]
      capital-u = "tailed-serifless"
      capital-z = "cursive-with-horizontal-crossbar"
      i = "serifed-diagonal-tailed"
      q = "diagonal-tailed-serifless"
      v = "cursive-serifed"
      w = "cursive-serifless"
      x = "cursive"
      y = "curly-turn-serifless"
      z = "cursive-with-horizontal-crossbar"
      ascii-single-quote = "straight"
      lig-neq = "slightly-slanted-dotted"

      [buildPlans.IosevkaCustom.ligations]
      enables = [
        "center-ops",
        "center-op-trigger-plus-minus-r",
        "center-op-trigger-equal-l",
        "center-op-trigger-equal-r",
        "center-op-trigger-bar-l",
        "center-op-trigger-bar-r",
        "center-op-trigger-angle-inside",
        "center-op-trigger-angle-outside",
        "center-op-influence-dot",
        "center-op-influence-colon",
        "arrow-l",
        "arrow-r",
        "counter-arrow-l",
        "counter-arrow-r",
        "trig",
        "eqeqeq",
        "eqeq",
        "lteq",
        "gteq",
        "exeqeqeq",
        "exeqeq",
        "exeq",
        "eqslasheq",
        "slasheq",
        "ltgt-diamond",
        "ltgt-slash-tag",
        "slash-asterisk",
        "plus-plus",
        "plus-plus-plus",
        "kern-dotty",
        "kern-bars",
        "logic",
        "llggeq",
        "html-comment",
        "hash-hash",
        "hash-hash-hash",
        "tilde-tilde",
        "tilde-tilde-tilde",
      ]
      disables = [
        "center-op-trigger-plus-minus-l",
        "eqlt",
        "lteq-separate",
        "eqlt-separate",
        "gteq-separate",
        "eqexeq",
        "eqexeq-dl",
        "tildeeq",
        "ltgt-ne",
        "ltgt-diamond-tag",
        "brst",
        "llgg",
        "colon-greater-as-colon-arrow",
        "brace-bar",
        "brack-bar",
        "underscore-underscore",
        "underscore-underscore-underscore",
        "minus-minus",
        "minus-minus-minus",
      ]

      [buildPlans.IosevkaCustom.widths.Normal]
      shape = 500
      menu = 5
      css = "normal"
    '';
  };
}
