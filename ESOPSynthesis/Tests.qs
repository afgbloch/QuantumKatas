//////////////////////////////////////////////////////////////////////
// This file contains testing harness for all tasks.
// You should not modify anything in this file.
// The tasks themselves can be found in Tasks.qs file.
//////////////////////////////////////////////////////////////////////

namespace Quantum.Kata.ESOPSynthesis {
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Logical;
    open Microsoft.Quantum.Math;

    // -------------------------------------------------------
    // HELPERS

    function ESOPprettyPrintTerm (term : Term) : String {
        mutable sTerm = "";
        for ((var, neg) in term!) {
            let sVar = ( neg ? "" | "¬") + $"x{var}";
            set sTerm = sTerm + sVar;
        }
        return sTerm;
    }

    function ESOPprettyPrint (esop : ESOP) : String {
        mutable sEsop = "";
        let aEsop = esop!;
        let size = Length(aEsop)-1;
        for (i in 0..size) {
            let term = aEsop[i];
            set sEsop = sEsop + ESOPprettyPrintTerm(term);
            if (i < size) {
                set sEsop = sEsop + " + ";
            }
        }
        return sEsop;
    }

    function ESOPEvaluateTermHelper (args : Bool[], term : Term) : Bool {
        let clause = term!;
        for ((var, isTrue) in clause) {
            if (isTrue != args[var-1]) {
                return false;
            }
        }
        return true;
    }

    function ESOPEvaluate (args : Bool[], esop : ESOP) : Bool {
        let terms = esop!;
        mutable trueTerm = 0;
        for (term in terms) {
            if (ESOPEvaluateTermHelper(args, term)) {
                set trueTerm = trueTerm + 1;
            }
        }
        return trueTerm % 2 == 1;
    }

    function ESOPTestDimensions(esop : ESOP, size : Int) : Unit {
        let terms = esop!;
        mutable min = 0x7FFFFFFFFFFFFFFF;
        mutable max = 0;
        for (term in terms) {
            let clause = term!;
            for ((var, isTrue) in clause) {
                set min = MinI(min, var);
                set max = MaxI(max, var);
            }
        }
        Fact(min > 0, $"Minimal variable is x{min} instead of x1");
        Fact(max <= size, $"Maximal variable is x{max} instead of x{size}");
    }

    function ESOPEqualityFact(esop1 : ESOP, esop2 : ESOP, size : Int) : Unit {
        ESOPTestDimensions(esop2, size);
        let assignments = Mapped(IntAsBoolArray(_, size), RangeAsIntArray(0..(2^size)-1));
        for (args in assignments) {
            let errorMsg = "Expected : " + ESOPprettyPrint(esop1) + " Got : " + ESOPprettyPrint(esop2);
            EqualityFactB(ESOPEvaluate(args, esop1), ESOPEvaluate(args, esop2), errorMsg);
        }
    }

    operation AssertOpEqual (size : Int, esop: ESOP, op_task : ((ESOP, Qubit[], Qubit) => Unit), op_ref : ((ESOP, Qubit[], Qubit) => Unit)) : Unit {
        using ((qs_task, qs_ref, target_ref, target_task) = (Qubit[size], Qubit[size], Qubit(), Qubit())) {
            for (k in 0 .. 2^size - 1) {
                // Prepare k-th bit vector
                let binary = IntAsBoolArray(k, size);
                
                // binary is little-endian notation, so the second vector tried has qubit 0 in state 1 and the rest in state 0
                ApplyPauliFromBitString(PauliX, true, binary, qs_ref);
                ApplyPauliFromBitString(PauliX, true, binary, qs_task);
                
                // Apply the operation
                op_ref(esop, qs_ref, target_ref);
                op_task(esop, qs_task, target_task);
                
                // Check that the result is what we'd expect to measure
                AssertQubit(M(target_ref), target_task);
            }
        }
    }

    // -------------------------------------------------------
    // TESTS

    operation ESOPExample_Test() : Unit {
        let esop_ref = ESOPExample_Reference();
        let esop_task = ESOPExample();
        ESOPEqualityFact(esop_ref, esop_task, 4);
    }

    operation ESOPCombine_Test() : Unit {
        let esop1 = ESOP([
            Term([(1, true), (3, false), (4, true)]),
            Term([(1, false), (2, true)])]);
        let esop2 = ESOP([
            Term([(4, true)]),
            Term([(2, false), (5, true)]),            
            Term([(1, false), (2, false)])]);
        let esop3 = ESOP([Term([(1, false)])]);

        let esop12_task = ESOPCombine(esop1, esop2);
        let esop12_ref = ESOPCombine_Reference(esop1, esop2);
        ESOPEqualityFact(esop12_task, esop12_ref, 5);

        let esop21_task = ESOPCombine(esop1, esop2);
        let esop21_ref = ESOPCombine_Reference(esop1, esop2);
        ESOPEqualityFact(esop21_task, esop21_ref, 5);

        let esop13_task = ESOPCombine(esop1, esop3);
        let esop13_ref = ESOPCombine_Reference(esop1, esop3);
        ESOPEqualityFact(esop13_task, esop13_ref, 4);

        let esop23_task = ESOPCombine(esop2, esop3);
        let esop23_ref = ESOPCombine_Reference(esop2, esop3);
        ESOPEqualityFact(esop23_task, esop23_ref, 5);
    }

    operation ESOPfromTT_Test () : Unit {
        let tt0s = TruthTable(0b00000000, 3);
        let esop0s_ref = ESOPfromTT_Reference(tt0s);
        let esop0s_tasks = ESOPfromTT_Reference(tt0s);
        ESOPEqualityFact(esop0s_ref, esop0s_tasks, 3);

        let tt1s = TruthTable(0b11111111, 3);
        let esop1s_ref = ESOPfromTT_Reference(tt1s);
        let esop1s_tasks = ESOPfromTT_Reference(tt1s);
        ESOPEqualityFact(esop1s_ref, esop1s_tasks, 3);

        let tt = TruthTable(0b01100001000001100001001110011111, 5);
        let esop_ref = ESOPfromTT_Reference(tt);
        let esop_tasks = ESOPfromTT_Reference(tt);
        ESOPEqualityFact(esop_ref, esop_tasks, 5);
    }

    operation ESOPEvaluateTerm_Test() : Unit {
        let esop = ESOP([
            Term([(1, true), (3, false), (4, true)]),
            Term([(1, false), (2, true)]),
            Term([(4, true)]),
            Term([(2, false), (5, true)]),            
            Term([(1, false), (2, false)]),
            Term([(1, false)])]);
        let size = 5;
        for (term in esop!) {
            let assignments = Mapped(IntAsBoolArray(_, size), RangeAsIntArray(0..(2^size)-1));
            for (args in assignments) {
                let eval_ref = ESOPEvaluateTerm_Reference(term, args);
                let eval_task = ESOPEvaluateTerm(term, args);
                let errorMsg = "For Term: " + ESOPprettyPrintTerm(term) + "Expected evaluation : " + BoolAsString(eval_ref) + " Got : " + BoolAsString(eval_task);
                EqualityFactB(eval_ref, eval_task, errorMsg);
            }
        }
    }
    
    operation ESOPApplyFunction_Test() : Unit {
        let esop = ESOP([
            Term([(1, true), (3, false), (4, true)]),
            Term([(1, false), (2, true)]),
            Term([(4, true)]),
            Term([(2, false), (5, true)]),            
            Term([(1, false), (2, false)]),
            Term([(1, false)])]);
        AssertOpEqual(5, esop, ESOPApplyFunction, ESOPApplyFunction_Reference);
    }
}


