-- ring_charge_haskell.hs — CARRIER #14: the defect-charge algebra of
-- emergence_04–_09 and RingRest.lean, re-carried into Haskell.
--
-- NEW LANGUAGE on this repo. The open-PR census already spans Julia, Lean,
-- Python (audit script), SQL (#10), Common Lisp (#11), Elixir (#12), Rust
-- (#13). Haskell is none of those: non-strict, pure, Hindley–Milner (not
-- dependent), with Integer bignums and an explicit ⊥ that is NOT Kleene's
-- third value. Run:
--   runghc carriers/ring_charge_haskell.hs
--   -- or:  ghc -O0 -o /tmp/ring_hs carriers/ring_charge_haskell.hs && /tmp/ring_hs
-- Exit 0 iff every check holds. Read the VERDICT line, not this prose.
--
-- OBJECT (unchanged from carriers #10/#12/#13): eleven worlds, m ∈ 2..5
-- with m^n ≤ 5000, exhaustive. Oracles:
--   rest ⟺ m|L .............. succ_ring_rest_iff   RingRest.lean §1
--   charge ≡ −L (rings) ..... defect_sum_invariant RingRest.lean §2 (P10)
--   (★) Σd ≡ Σ(1−outdeg)s − n . charge_formula      RingRest.lean §3
--   one-shared-mark dial .... charge_dial          RingRest.lean §3 (P13/P19)
--   outdeg-3 / dial image ... P20 + P26            emergence_09 + PR #9
--   unheard mark +1 dial .... P21                  emergence_09.jl
--
-- GAINED (over the imperative/declarative hosts):
--   * Laziness is a first-class instrument. The state space is a pure list
--     comprehension; nothing mutates under the fold. _03's in-place sweep
--     order is not merely avoided — a pure fold has no place to hide a
--     write-back. (The crime is still expressible via ST/IO; purity makes
--     it LOUD, as Elixir's immutability did for #12.)
--   * Integer is unbounded (like Elixir/CL). P10 is checked on a state at
--     ±10^38 no Julia Int64 / SQL INTEGER can hold. Int (machine) is the
--     SEPARATE type that wraps — photographed below, not silently used.
--   * ⊥ is a third value that is NOT K3: undefined == undefined diverges
--     (or raises), it does not return a third truth. P16's rest state is
--     about propagating negation, not about bottoms. Photographed.
--
-- LOST (relative to #10 SQL):
--   * Declarative inexpressibility of sweep order is gone (IO can re-commit
--     it). The pure core of THIS file does not.
--   * No native K3. Maybe is opt-in; Nothing == Nothing is True.
--
-- CONFLICT DECLARED: the eleven worlds are transcribed from the same
-- emergence_05/_07/_09 constructors every carrier uses — replicated, not
-- re-derived. The next stranger who wants independence should generate
-- wirings from a kernel statement, not from this table.
--
-- No packages. base only. GHC ≥ 9.

{-# OPTIONS_GHC -Wno-x-partial -Wno-unrecognised-warning-flags #-}

module Main where

import Data.List (foldl', nub, sort)
import Data.Maybe (isNothing)
import System.Exit (exitWith, ExitCode(..))
import Text.Printf (printf)

-- =====================================================================
-- Worlds: mark -> inputs it hears (1-based, matching #10/#12/#13).
-- =====================================================================

type Wiring = [(Int, [Int])]

ring :: Int -> Wiring
ring n = [(i, [if i == 1 then n else i - 1]) | i <- [1..n]]

worlds :: [(String, Int, Wiring)]
worlds =
  [ ("ring2", 2, ring 2)
  , ("ring3", 3, ring 3)
  , ("ring4", 4, ring 4)
  , ("ring5", 5, ring 5)
  , ("ring6", 6, ring 6)
  , ("fig8_23", 4, [(1,[2,4]),(2,[1]),(3,[1]),(4,[3])])
  , ("fig8_33", 5, [(1,[3,5]),(2,[1]),(3,[2]),(4,[1]),(5,[4])])
  , ("tworings_23", 5, [(1,[2]),(2,[1]),(3,[5]),(4,[3]),(5,[4])])
  , ("chord", 4, [(1,[4]),(2,[1]),(3,[2,1]),(4,[3])])
  , ("w3", 4, [(1,[4]),(2,[1]),(3,[2,1]),(4,[3,1])])
  , ("w0", 3, [(1,[2]),(2,[1]),(3,[])])
  ]

ringNames :: [String]
ringNames = ["ring2","ring3","ring4","ring5","ring6"]

lookupW :: String -> (Int, Wiring)
lookupW name =
  case lookup name [(n,(sz,w)) | (n,sz,w) <- worlds] of
    Just x -> x
    Nothing -> error ("unknown world: " ++ name)

-- =====================================================================
-- Algebra. Floored mod throughout (Haskell's `mod` on Integer IS floored
-- for positive modulus; `rem` is truncated — FP2 photographs both).
-- =====================================================================

emod :: Integer -> Integer -> Integer
emod x m = mod x m

outdeg :: Wiring -> Int -> Int -> Integer
outdeg wir n j =
  sum [ fromIntegral (length (filter (== j) ins))
      | i <- [1..n], let ins = maybe [] id (lookup i wir) ]

defect :: Wiring -> [Integer] -> Integer -> Int -> Integer
defect wir s m i =
  let ins = maybe [] id (lookup i wir)
      insum = sum [ s !! (j - 1) | j <- ins ]
  in emod (s !! (i - 1) - insum - 1) m

charge :: Wiring -> [Integer] -> Integer -> Int -> Integer
charge wir s m n =
  emod (sum [ defect wir s m i | i <- [1..n] ]) m

predicted :: Wiring -> [Integer] -> Integer -> Int -> Integer
predicted wir s m n =
  let acc = sum [ (1 - outdeg wir n j) * (s !! (j - 1)) | j <- [1..n] ]
  in emod (acc - fromIntegral n) m

-- every state of (m,n) as a list of digits, mark 1 at index 0
states :: Integer -> Int -> [[Integer]]
states m n =
  let total = m ^ n
      dig sid k = emod (sid `div` (m ^ k)) m
  in [ [ dig sid k | k <- [0..n-1] ] | sid <- [0 .. total - 1] ]

restExists :: Wiring -> Integer -> Int -> Bool
restExists wir m n =
  any (\s -> all (\i -> defect wir s m i == 0) [1..n]) (states m n)

igcd :: Integer -> Integer -> Integer
igcd a 0 = abs a
igcd a b = igcd b (a `mod` b)

-- =====================================================================
-- Court
-- =====================================================================

data Row = Row String String String Bool  -- name, got, expect, ok

check :: String -> String -> String -> Bool -> Row
check name got expect ok = Row name got expect ok

showRow :: Row -> String
showRow (Row name got expect ok) =
  printf "%-48s got=%-14s expect=%-14s %s"
         name (take 14 got) (take 14 expect) (if ok then "ok" else "FAIL")

boolStr :: Bool -> String
boolStr True  = "True"
boolStr False = "False"

intStr :: (Show a) => a -> String
intStr = show

grid :: [(String, Integer, Int, Wiring)]
grid =
  [ (name, m, n, wir)
  | (name, n, wir) <- worlds
  , m <- [2..5]
  , m ^ n <= (5000 :: Integer)
  ]

buildRows :: [Row]
buildRows = concat
  [ starRows
  , restRows
  , p10Rows
  , dialRows
  , p20p26Rows
  , p26CtrlRows
  , p21Rows
  , mutantRows
  , fingerprintRows
  ]

-- (★) on every grid cell
starRows :: [Row]
starRows =
  [ let bad = length [ () | s <- states m n
                          , charge wir s m n /= predicted wir s m n ]
    in check ("star: " ++ w ++ " m=" ++ show m)
             (intStr bad) "0" (bad == 0)
  | (w, m, n, wir) <- grid
  ]

-- rest ⟺ m | L on rings
restRows :: [Row]
restRows =
  [ let (n, wir) = lookupW w
        got = restExists wir m n
        expect = (fromIntegral n `mod` m == 0)
    in check ("rest_iff_dvd: " ++ w ++ " m=" ++ show m)
             (boolStr got) (boolStr expect) (got == expect)
  | w <- ringNames, m <- [2..5], let (n,_) = lookupW w, m ^ n <= (5000 :: Integer)
  ]

-- P10: rings, charge is state-free and ≡ −L
p10Rows :: [Row]
p10Rows =
  [ let (n, wir) = lookupW w
        ds = nub [ charge wir s m n | s <- states m n ]
        expect = [emod (negate (fromIntegral n)) m]
    in check ("P10 state-free: " ++ w ++ " m=" ++ show m)
             (intStr (sort ds)) (intStr expect) (sort ds == expect)
  | w <- ringNames, m <- [2..5], let (n,_) = lookupW w, m ^ n <= (5000 :: Integer)
  ]

-- P13/P19 dial on one-shared-mark worlds
dialRows :: [Row]
dialRows =
  [ let (n, wir) = lookupW w
        bad = length [ () | s <- states m n
                          , charge wir s m n /= emod (negate (s !! 0) - fromIntegral n) m ]
    in check ("dial: " ++ w ++ " m=" ++ show m)
             (intStr bad) "0" (bad == 0)
  | w <- ["fig8_23","fig8_33","chord"]
  , m <- [2..5]
  , let (n,_) = lookupW w
  , m ^ n <= (5000 :: Integer)
  ]

-- P20 law + P26 gcd-vanishing on w3 (d = −2)
p20p26Rows :: [Row]
p20p26Rows =
  concat
  [ let (n, wir) = lookupW "w3"
        bad = length [ () | s <- states m n
                          , charge wir s m n /= emod (negate (2 * (s !! 0)) - fromIntegral n) m ]
        spread = length (nub [ charge wir s m n | s <- states m n ])
        expectSpread = m `div` igcd 2 m
    in [ check ("P20 dial: w3 m=" ++ show m) (intStr bad) "0" (bad == 0)
       , check ("P26 gcd-vanishing: w3 m=" ++ show m)
               (intStr spread) (intStr expectSpread) (fromIntegral spread == expectSpread)
       ]
  | m <- [2..5]
  ]

-- P26 control: outdeg-2 dial (d = −1) never collapses
p26CtrlRows :: [Row]
p26CtrlRows =
  [ let n = 4
        -- predicted image size of charge ≡ −s₁ − n under free s₁
        spread = length (nub [ emod (negate s1 - fromIntegral n) m | s1 <- [0..m-1] ])
    in check ("CONTROL P26: outdeg-2 dial never collapses m=" ++ show m)
             (intStr spread) (intStr m) (fromIntegral spread == m)
  | m <- [2..5]
  ]

-- P21 unheard-mark dial
p21Rows :: [Row]
p21Rows =
  [ let (n, wir) = lookupW "w0"
        bad = length [ () | s <- states m n
                          , charge wir s m n /= emod ((s !! 2) - fromIntegral n) m ]
    in check ("P21 unheard-mark dial: w0 m=" ++ show m)
             (intStr bad) "0" (bad == 0)
  | m <- [2..5]
  ]

-- mutant controls must fire
mutantRows :: [Row]
mutantRows =
  let (n, wir) = lookupW "chord"
      m = 3
      mutStar = length
        [ () | s <- states m n
             , let wrong = emod (sum [ (1 - outdeg wir n j) * (s !! (j-1)) | j <- [1..n] ]) m
             , charge wir s m n /= wrong ]
      mutDial = length
        [ () | s <- states m n
             , charge wir s m n /= emod (negate ((s !! 0) + 5) - fromIntegral n) m ]
  in [ check "CONTROL mutant (★ without −n) must fire"
             (boolStr (mutStar > 0)) "True" (mutStar > 0)
     , check "CONTROL mutant (dial −(s₁+5)) must fire"
             (boolStr (mutDial > 0)) "True" (mutDial > 0)
     ]

-- =====================================================================
-- Fingerprints — facts about HASKELL, not about the ring algebra.
-- =====================================================================
fingerprintRows :: [Row]
fingerprintRows =
  let
    -- FP1: Integer is unbounded; Int wraps (two types, two policies —
    -- the (host, *representation*) split, one level below PR #9's
    -- (host, build-profile) finding for Rust).
    big :: Integer
    big = 2 ^ (63 :: Int)
    fp1a = check "FPRINT Integer: 2^63 exact (no wrap)"
                 (intStr (big + 1 - big)) "1" (big + 1 - big == 1)
    fp1b = check "FPRINT Integer: 2^126 digit count"
                 (intStr (length (show (big * big)))) "38"
                 -- 2^126 = 85070591730234615865843651857942052864 → 38 digits
                 (length (show (big * big)) == 38)
    -- Int on a 64-bit host: maxBound + 1 wraps (or errors in some
    -- contexts; with plain Num it wraps in GHC's default).
    fp1c = check "FPRINT Int: maxBound+1 wraps to minBound"
                 (intStr (maxBound + 1 == (minBound :: Int))) "True"
                 (maxBound + 1 == (minBound :: Int))

    -- FP2: mod vs rem — floored vs truncated, both shipped, both named.
    -- Same plurality Elixir photographed; same silent choice Julia/SQL made.
    fp2a = check "FPRINT mod: rem is TRUNCATED (rem (-7) 3)"
                 (intStr ((-7 :: Integer) `rem` 3)) "-1"
                 (((-7 :: Integer) `rem` 3) == -1)
    fp2b = check "FPRINT mod: mod is FLOORED (mod (-7) 3)"
                 (intStr ((-7 :: Integer) `mod` 3)) "2"
                 (((-7 :: Integer) `mod` 3) == 2)

    -- FP3: equality. Haskell's Eq is a type class; arity is 2 at the
    -- method, but the AXIS is "instance-provided". For Integer it is
    -- decidable and total; for Double it is IEEE (NaN ≠ NaN). No host in
    -- the census splits equality by *type class dispatch* — that is this
    -- carrier's axis.
    fp3a = check "FPRINT Eq Integer: 1 == 1"
                 (boolStr ((1 :: Integer) == 1)) "True" True
    fp3b = check "FPRINT Eq Double: NaN /= NaN (IEEE, not reflexive)"
                 (boolStr (let n = (0/0 :: Double) in n /= n)) "True"
                 (let n = (0/0 :: Double) in n /= n)
    fp3c = check "FPRINT Eq Double: 0.1+0.2 /= 0.3"
                 (boolStr (((0.1 + 0.2) :: Double) == 0.3)) "False"
                 (not ((((0.1 + 0.2) :: Double) == 0.3)))

    -- FP4: Maybe is NOT K3. Nothing == Nothing is True (total Eq on
    -- Maybe Bool). Default negation on Bool does not extend; you must
    -- write the propagating twist yourself — same lesson #12/#13 drew.
    dom :: [Maybe Bool]
    dom = [Just True, Just False, Nothing]
    coercing :: Maybe Bool -> Maybe Bool
    coercing Nothing = Just True          -- coerce absence → True (Elixir !)
    coercing (Just b) = Just (not b)
    propagating :: Maybe Bool -> Maybe Bool
    propagating Nothing = Nothing         -- propagate absence (SQL/Julia)
    propagating (Just b) = Just (not b)
    fp4a = check "P16: equality is TOTAL here (Nothing == Nothing)"
                 (boolStr (Nothing == (Nothing :: Maybe Bool))) "True"
                 (Nothing == (Nothing :: Maybe Bool))
    fp4b = check "P16: COERCING twist has ZERO fixed points"
                 (intStr (length [ v | v <- dom, coercing v == v ])) "0"
                 (null [ v | v <- dom, coercing v == v ])
    fp4c = check "P16: PROPAGATING twist has exactly one fixed point"
                 (intStr (length [ v | v <- dom, propagating v == v ])) "1"
                 ([ v | v <- dom, propagating v == v ] == [Nothing])

    -- FP5: ⊥ is not a third truth value. We cannot put `undefined` in a
    -- pure Eq test without diverging; the fingerprint is that the type
    -- system will not hand you a rest state for free the way SQL's NULL
    -- does. Recorded as: isNothing distinguishes absence WITHOUT being
    -- bottom, and bottom is opt-in via undefined — never the default of
    -- an unfinished pattern in a total function we write here.
    fp5a = check "FPRINT bottom: isNothing is a total test on Maybe"
                 (boolStr (isNothing (Nothing :: Maybe Bool))) "True"
                 (isNothing (Nothing :: Maybe Bool))
    fp5b = check "FPRINT bottom: Just is not Nothing"
                 (boolStr (isNothing (Just False))) "False"
                 (not (isNothing (Just False)))

    -- FP6: bignum P10 witness — a state Lean quantifies over and Julia
    -- Int64 cannot hold. Charge on ring2 at m=5 with s = [10^38, 10^38]
    -- must still equal −2 mod 5. (defect algebra is linear; magnitude
    -- is free.)
    huge = 10 ^ (38 :: Int)
    (nr, wirr) = lookupW "ring2"
    chHuge = charge wirr [huge, huge] 5 nr
    fp6 = check "FPRINT bignum state: P10 at |s|=10^38 on ring2 m=5"
                (intStr chHuge) (intStr (emod (-2) 5))
                (chHuge == emod (-2) 5)

  in [fp1a, fp1b, fp1c, fp2a, fp2b, fp3a, fp3b, fp3c, fp4a, fp4b, fp4c, fp5a, fp5b, fp6]

-- =====================================================================
-- Receipt. Pin the check COUNT so a truncated run cannot pass (F2/C1
-- discipline). Also pin a digest of names so a  N-line dummy battery
-- fails even when the count matches (PR #8's soft-spot repair).
-- =====================================================================

expectedChecks :: Int
expectedChecks = 125
-- breakdown: star 43 + rest 19 + p10 19 + dial 12 + p20 4 + p26 4
--          + p26ctrl 4 + p21 4 + mutants 2 + fingerprints 14 = 125.

nameDigest :: [String] -> String
nameDigest ns =
  let sorted = sort ns
      step :: Integer -> String -> Integer
      step acc s =
        let hstr = foldl' (\a c -> a * 33 + fromIntegral (fromEnum c)) (0 :: Integer) s
        in (acc * 1000003 + hstr) `mod` (2 ^ (64 :: Integer))
      h = foldl' step (0 :: Integer) sorted
  in printf "%016x" (h :: Integer)

-- Digest pinned after first green run. A renamed or gutted battery
-- fails even at the right count (PR #8 soft-spot repair, ported).
expectedDigest :: String
expectedDigest = "7cf171fe3381f827"

main :: IO ()
main = do
  let rows = buildRows
      n = length rows
      mismatches = length [ () | Row _ _ _ False <- rows ]
      names = [ name | Row name _ _ _ <- rows ]
      dig = nameDigest names
  mapM_ (putStrLn . showRow) rows
  printf "VERDICT mismatches=%d checks=%d digest=%s\n" mismatches n dig
  -- count pin
  let countOk = n == expectedChecks
      -- digest pin is armed only after PLACEHOLDER is replaced
      digestArmed = expectedDigest /= "PLACEHOLDER_REPLACE_AFTER_FIRST_RUN"
      digestOk = not digestArmed || dig == expectedDigest
  if not countOk then
    printf "COUNT PIN FAIL: got %d checks, expected %d\n" n expectedChecks
  else pure ()
  if digestArmed && not digestOk then
    printf "DIGEST PIN FAIL: got %s, expected %s\n" dig expectedDigest
  else pure ()
  if mismatches == 0 && countOk && digestOk
    then exitWith ExitSuccess
    else exitWith (ExitFailure 1)
