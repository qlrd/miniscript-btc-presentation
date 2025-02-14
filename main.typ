#import "@preview/slydst:0.1.0": *

#show: slides.with(
  title: "Krux and miniscript",
  subtitle: "an introduction to BIP379 and a little game",
  date: none,
  authors: ("qlrd", ),
  layout: "medium",
  ratio: 4/3,
  title-color: orange,
)


== Miniscript

#align(horizon + center)[
    #definition(title: "BIP 379")[
        (...) a language for writing (a subset of) *Bitcoin Scripts* in a structured way, enabling analysis, composition, generic signing and more. @bip379 
    ]
]

= Back to the basics

== Bitcoin script

#align(horizon + center)[
    #definition(title: "")[
        (...) an unusual stack-based language with many edge cases designed for implementing spending conditions consisting of various combinations of signatures, hash locks, and time locks. @bip379
    ]
]

== Bitcoin script

Common transactions from @wiki_script and @mastering_bitcoin

#align(horizon + center)[
    #table(
        columns: (auto, auto, auto),
        inset: 10pt,
        align: horizon,
        table.header(
            [*Comment*], [*Unlock*],[*Lock*]
        ),
        `P2PK`, `<sig> <pk>`, `OP_CHECKSIG`,
        `P2PKH`, `<sig> <pk>`, `OP_DUP OP_HASH160 <pkh> OP_EQUALVERIFY OP_CHECKSIG`,
        `Multisig 2-of-3`, `OP_0 <sigA> <sigB>`, `2 <pkA> <pkB> <pkC> 3 OP_CHECKMULTISIG`,
    )
]

== Bitcoin script

Freezing funds until a time in the future from @wiki_script

#align(horizon + center)[
    #table(
        columns: (auto, auto),
        inset: 10pt,
        align: horizon,
        table.header(
            [*Unlock*],[*Lock*]
        ),
        `<sig> <pk>`, `<expiry time> OP_CHECKLOCKTIMEVERIFY OP_DROP OP_DUP OP_HASH160 <pkh> OP_EQUALVERIFY OP_CHECKSIG`
    )
]

== Bitcoin script

Timelock variable multisignature from  @mastering_bitcoin: 2-of-3 multisig; after 30 days 1-of-3 with a lawyers's signature; after 90 days the lawyer's signature.

#align(horizon + center)[
    #table(
        columns: (auto, auto),
        inset: 10pt,
        align: horizon,
        table.header(
            [*Unlock*],[*Lock*]
        ),
        `OP_0 <sigA> <sigB> OP_TRUE OP_TRUE`, `OP_IF OP_IF 2 OP_ELSE <30 days> OP_CHECKSEQUENCEVERIFY OP_DROP <sigD> OP_CHECKSIGVERIFY 1 OP_ENDIF <sigA> <sigB> <sigC> 3 OP_CHECKMULTISIG OP_ELSE <90 days> OP_CHECKSEQUENCEVERIFY OP_DROP <sigD> OP_CHECKSIG OP_ENDIF`
    )
]


= The issue @bip379

= 

Given a combination of spending conditions, it is challenging to:

- find the most economical script to implement it;

- implement a composition of their spending conditions;

- find out what spending conditions it permits.

...

= The motivation

=

*Miniscript* has a structure that allows composition: a representation for *scripts* that makes these type of operations possible.

= Specification @bip379

== Specification

#align(horizon + center)[
    Miniscript analyzes scripts to determine properties.
]

== Specification

#align(horizon)[
    *Not expected* to be used with:

    - BIP 16 (p2sh);

    *Expected* to  be used within:

    - BIP 382: `wsh` descriptor;
    - BIP 386: `tr` descriptor.

    And together with:

    - BIP 380: Key expressions:

    `[<fingerprint>/<purpose>/<cointype>/<index>]`
]

== Specification
#align(horizon)[
    From a user's perspective, Miniscript is not a separate language, but rather a significant expansion of the descriptor language. @bip379
]

== Specification
#align(horizon)[
    Liana's simple inheritance wallet @jean_gist_liana_wsh.
    
    `wsh(` \
    `  or_d(` \
    `    pk([07fd816d/48'/1'/0'/2']tpub...wd5/<0;1>/*),` \
    `    and_v(` \
    `      v:pkh([da855a1f/48'/1'/0'/2']tpub...Hg5/<0;1>/*),` \
    `      older(36)` \
    `    )` \
    `  )` \
    `)#lz4jfr7g`
    
]

== Specification
#align(horizon)[
    Liana's simple inheritance wallet TR @jean_gist_liana_tr. First key expression is a `NUMS` ("nothing-up-my-sleeves") point @jaonoctus_nums.
       
    `tr(` \
    `  [07fd816d/48'/1'/0'/2']tpub...mwd5/<0;1>/*,` \
    `  and_v(` \
    `    v:pk([da855a1f/48'/1'/0'/2']tpub...Hg5/<0;1>/*),` \
    `    older(36)` \
    `  )` \
    `)#506utvsp`
]

== Specification
#align(horizon)[
    Liana's variable multisig @jean_gist_liana_mwsh.
    
    `wsh(` \
    `  or_d(` \
    `    multi(2,` \
    `      [07fd816d/48'/1'/0'/2']tpub...wd5/<0;1>/*,` \
    `      [da855a1f/48'/1'/0'/2']tpub...Hg5/<0;1>/*` \
    `    ),` \
    `    and_v(` \
    `      v:thresh(2,` \
    `        pkh([07fd816d/48'/1'/0'/2']tpub...mwd5/<2;3>/*),` \
    `        a:pkh([da855a1f/48'/1'/0'/2']tpub...Hg5/<2;3>/*),` \
    `        a:pkh([cdef7cd9/48'/1'/0'/2']tpub...Ak2/<0;1>/*)` \
    `      ),` \
    `      older(36)` \
    `    )` \
    `  )`
    `)#wa74c6se`
]

== Specification
#align(horizon)[
    Liana's variable multisig TR @jean_gist_liana_mtr. First key expression is a `NUMS` ("nothing-up-my-sleeves") point @jaonoctus_nums.

    `tr(tpub...pMN/<0;1>/*, {` \
    `  and_v(` \
    `    v:multi_a(2,` \
    `      [07fd816d/48'/1'/0'/2']tpub...mwd5/<2;3>/*,` \
    `      [da855a1f/48'/1'/0'/2']tpub...DHg5/<2;3>/*,` \
    `      [cdef7cd9/48'/1'/0'/2']tpub...SAk2/<0;1>/*` \
    `    ),` \
    `    older(36)` \
    `  ),` \
    `  multi_a(2,` \
    `    [07fd816d/48'/1'/0'/2']tpub...mwd5/<0;1>/*,` \
    `    [da855a1f/48'/1'/0'/2']tpub...DHg5/<0;1>/*` \
    `  )` \
    `})#tvh3u2lu`
]


== Specification 
#align(horizon + center)[
    #definition(title: "")[
        *Miniscript* consists of a set of *script* fragments which are designed to be safely and correctly composable (...) targeted by spending policy compilers
    ]
]

= Implementations

#show link: underline

- #link("https://github.com/sipa/miniscript")[Peter Wuile's reference implementation];

- C++:
    - #link("https://github.com/bitcoin/bitcoin/blob/master/src/script/miniscript.cpp")[Bitcoin-core];
    
- Rust:
    - #link("https://github.com/rust-bitcoin/rust-miniscript")[rust-miniscript];
    - #link("https://github.com/wizardsardine/liana")[Liana];

- Go:
    - #link("https://bitbox.swiss/blog/understanding-bitcoin-miniscript-part-3")[Tutorial: Understanding Bitcoin Miniscript - Part III];

- Python:
    - #link("https://github.com/diybitcoinhardware/embit/blob/master/src/embit/descriptor/miniscript.py")[Embit's miniscript.py]
    - #link("https://github.com/odudex/krux/tree/p2wsh_miniscript")[Krux (branch p2wsh_miniscript)];
    - #link("https://github.com/odudex/krux/tree/tr_miniscript")[Krux (branch tr_miniscript)];


== Hands on

== Hands on: setup a single-inheritance scheme
#show link: underline
#align(horizon + center)[
    #figure(
        image("images/download-krux.svg", width: 50%, format: "svg"),
        caption: [
            Before start, download a Krux demo android app
            #link("https://github.com/odudex/krux_binaries/blob/main/Android/Krux_25.01.beta8_Android_0.2.apk")[https://github.com/odudex/krux_binaries/blob/main/Android/Krux_25.01.beta8_Android_0.2.apk]
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/download-liana.svg", width: 50%, format: "svg"),
        caption: [
            Before start, download Liana coordinator in your computer
            #link("https://wizardsardine.com/liana/")[https://wizardsardine.com/liana/]
        ]
    )
]

#align(horizon + center)[
    #figure(
        image("images/liana-1.png", width: 80%),
        caption: [
            We will select *signet* to not risk our beloved sats.
        ]
    )
]

#align(horizon + center)[
    #figure(
        image("images/liana-2.png", width: 80%),
        caption: [
            Selecting *Simple inheritance* scheme.
        ]
    )
]

#align(horizon + center)[
    #figure(
        image("images/liana-3.png", width: 80%),
        caption: [
            An explanation how *Simple inheritance* scheme works.
        ]
    )
]

#align(horizon + center)[
    #figure(
        image("images/liana-4.png", width: 80%),
        caption: [
            Liana's menu to setup *Simple inheritance*.
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/liana-5.png", width: 80%),
        caption: [
            Liana's menu to setup *Simple inheritance*.
        ]
    )
]

#align(horizon + center)[
    #figure(
        image("images/liana-6.png", width: 80%),
        caption: [
            Liana's waiting for the first (key-expression + xpub) to setup *Simple inheritance*.
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/krux-1.jpeg", width: 25%),
        caption: [
            Load a previous created wallet on *Krux*.
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/krux-2.jpeg", width: 25%),
        caption: [
            Select *Via Camera* to Load.
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/krux-3.jpeg", width: 25%),
        caption: [
            Select *QR Code* to scan.
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/krux-4.jpeg", width: 25%),
        caption: [
            Decrypt a encrypted mnemoninc.
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/krux-5.jpeg", width: 25%),
        caption: [
            Select *Type Key* to type a decrypt key.
            Alternatively, you can scan a previous created QRCode key.
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/krux-6.jpeg", width: 25%),
        caption: [
            *Type Key* keyboard. Try something like `'test'` or another one.
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/krux-7.jpeg", width: 25%),
        caption: [
            `'test'` was typed as the decrypt key.
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/krux-8.jpeg", width: 25%),
        caption: [
            Decrypted a double-mnemonic (see `*`, the first 12 words are a valid mnemonic;
            the last 12 are a valid mnemonic and the 24 words are another valid mnemonic).
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/krux-9.jpeg", width: 25%),
        caption: [
            Loaded wallet secured by an optional BIP39 passphrase.
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/krux-10.jpeg", width: 25%),
        caption: [
            Select *Type BIP39 Passphrase* to access keyboard.
            Alternatively you can scan an QRCode encoded one.
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/krux-11.jpeg", width: 25%),
        caption: [
            Select *Type BIP39 Passphrase* to access keyboard.
            Alternatively you can scan an QRCode encoded one.
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/krux-12.jpeg", width: 25%),
        caption: [
            Krux ask for passphrase confirmation.
            Remember that different passphrases leads to different wallets!
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/krux-13.jpeg", width: 25%),
        caption: [
            A different wallet was loaded (verify the upper checksum).
            But we still need to customize some stuffs.
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/krux-14.jpeg", width: 25%),
        caption: [
            Let's change the network, since we're testing!

        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/krux-15.jpeg", width: 25%),
        caption: [
            For signet wallet in Liana, we can use a testnet on Krux.
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/krux-16.jpeg", width: 25%),
        caption: [
            Let's change policy to be able to do a inheritance scheme.
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/krux-17.jpeg", width: 25%),
        caption: [
            Select miniscript policy.
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/krux-18.jpeg", width: 25%),
        caption: [
            Then select the between BIP382 (wsh) or BIP386 (tr) descriptors.
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/krux-19.jpeg", width: 25%),
        caption: [
            *Optional* you can edit your derivation path for the inheritance scheme.
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/krux-20.jpeg", width: 25%),
        caption: [
            *Optional* For educational purposes, let be the default `m/48'/1'/0'/2'`.
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/krux-21.jpeg", width: 25%),
        caption: [
            Now we can back to main logged menu.
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/krux-22.jpeg", width: 25%),
        caption: [
            All done! 🎉And load properly the wallet
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/krux-23.jpeg", width: 25%),
        caption: [
            We need to load the key expression + tpub.
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/krux-24.jpeg", width: 25%),
        caption: [
            If you have a real krux device, it's recomended to load *TPUB - text*.
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/krux-25.jpeg", width: 25%),
        caption: [
            For real devices, save the key expression + tpub into a SDCard. 
        ]
    )
]

#align(horizon + center)[
    #figure(
        image("images/krux-26.jpeg", width: 25%),
        caption: [
            For demo app, press *TPUB - QRCode*.
        ]
    )
]

#align(horizon + center)[
    #figure(
        image("images/sparrow-0.png", width: 75%),
        caption: [
            Open another coordinator like Sparrow and start it on signet.
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/sparrow-1.png", width: 75%),
        caption: [
            "Create" a new wallet.
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/sparrow-2.png", width: 90%),
        caption: [
            Select xPub/watch Only Wallet
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/sparrow-3.png", width: 110%),
        caption: [
            Click on the 📷 icon to start the scanning procedure.
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/sparrow-4.png", width: 100%),
        caption: [
            Once scanned, you can see the derivation-path ant the tpub.
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/sparrow-5.png", width: 100%),
        caption: [
            In upper section, you'll click in the "Next" button near to  📷 icon.
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/sparrow-7.png", width: 100%),
        caption: [
            Copy the fingerprint + tpub (the blue part).
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/liana-8.png", width: 100%),
        caption: [
            Key fingerprint + tpub copied to Liana and an Alias for it.
        ]
    )
]


= Exercise 1

== Exercise 1
#align(horizon + center)[
    #figure(
        image("images/liana-9.png", width: 100%),
        caption: [
            Set a timelock to your second key.
        ]
    )
]
= Exercise 2

== Exercise 2
#align(horizon + center)[
    #figure(
        image("images/liana-10.png", width: 100%),
        caption: [
            Now you will repeat all previous procedures to a heir key.
        ]
    )
]

= Backup your descriptor

== Backup your descriptor

#align(horizon + center)[
    #figure(
        image("images/liana-11.png", width: 100%),
        caption: [
            Check if all is ok.
        ]
    )
]


#align(horizon + center)[
    #figure(
        image("images/liana-12.png", width: 75%),
        caption: [
            Check the policy and backup the miniscript descriptor on a SDCard to load it with Krux.
        ]
    )
]

= Select a new node

== Select a new node

#align(horizon + center)[
    #figure(
        image("images/liana-13.png", width: 75%),
        caption: [
            Select a proper node. For the workshop purpose, select Liana Connect.
        ]
    )
]
#align(horizon + center)[
    #figure(
        image("images/liana-14.png", width: 75%),
        caption: [
            Put your email to receive an OTP. 
        ]
    )
]

= Thanks!

= Bibliography

#bibliography("main.bib")
