namespace Quantum.Kata.ESOPSynthesis {
    
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert as Convert;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Logical;
    open Microsoft.Quantum.Measurement;

    // ------------------------------------------------------------------------
    // From TruthTables

    newtype TruthTable = (bits : Int, numVars : Int);

    function AllMinterms_Reference (tt : TruthTable) : Int[] {
        return Mapped(
                   Fst<Int, Bool>,
                   Filtered(
                       Compose(EqualB(true, _), Snd<Int, Bool>),
                       Enumerated(Convert.IntAsBoolArray(tt::bits, 2^tt::numVars))
                   )
               );
    }
    
    // ------------------------------------------------------------------------
    newtype Term = (Int, Bool)[];
    newtype ESOP = Term[];
    
    // Task 1. ESOP example of f() = x1x2 + x3~x4
    function ESOPExample() : ESOP {
        let t1 = Term([(1, true), (2, true)]);
        let t2 = Term([(1, true)]); // update the value of t2
        return ESOP([t1, t2]);
    } 

    // Task 2. Combination of two ESOP
    function ESOPCombine(esop1: ESOP, esop2: ESOP) : ESOP {
        fail ("Task 2 not implemented!");
    }

    // Task 3. Convert truth table into canonical ESOP
    function ESOPfromTT(tt: TruthTable) : ESOP {
        fail ("Task 3 not implemented!");
    }

    // Task 4. Evaluate an ESOP term with respect to the varibles assignment
    function ESOPEvaluateTerm(term: Term, assignment : Bool[]) : Bool {
        fail ("Task 4 not implemented!");
    }

    // Task 5. Apply ESOP as quantum operatiom
    operation ESOPApplyFunction(esop : ESOP, controls : Qubit[], target : Qubit) : Unit {
        fail ("Task 5 not implemented!");
    }  

}
