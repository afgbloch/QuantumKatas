//////////////////////////////////////////////////////////////////////
// This file contains reference solutions to all tasks.
// The tasks themselves can be found in Tasks.qs file.
// We recommend that you try to solve the tasks yourself first,
// but feel free to look up the solution if you get stuck.
//////////////////////////////////////////////////////////////////////

namespace Quantum.Kata.ESOPSynthesis {

    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert as Convert;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Logical;
    open Microsoft.Quantum.Measurement;

    // Task 1. ESOP example of f() = x1x2 + x3~x4
    function ESOPExample_Reference() : ESOP {
        let t1 = Term([(1, true), (2, true)]);
        let t2 = Term([(3, true), (4, false)]);
        return ESOP([t1, t2]);
    } 

    // Task 2. Combination of two ESOP
    function ESOPCombine_Reference(esop1: ESOP, esop2: ESOP) : ESOP {
        return ESOP(esop1! + esop2!);
    }

    // Task 3. Convert truth table into canonical ESOP
    function ESOPfromTT_Reference(tt: TruthTable) : ESOP {
        let (bits, nVar) = tt!;
        mutable esop = new Term[0];
        for (i in AllMinterms_Reference(tt)) {
            mutable t1 = new(Int, Bool)[0];
            let range = tt::numVars..-1..1;
            mutable index = i;
            for (var in range) {
                if (index < 2^(var-1) ) {
                    set t1 = t1 + [(var, false)];
                } else {
                    set t1 = t1 + ([(var, true)]);
                    set index = index - 2^(var-1);
                }
            }
            set esop = esop + [Term(t1)];
        }
        return ESOP(esop);
    }

    // Task 4. Evaluate an ESOP term with respect to the varibles assignment
    function ESOPEvaluateTerm_Reference(term: Term, assignment : Bool[]) : Bool {
        let clause = term!;
        for ((var, isTrue) in clause) {
            if (isTrue != assignment[var-1]) {
                return false;
            }
        }
        return true;
    }

    // Task 5. Apply ESOP as quantum operatiom
    operation ESOPApplyFunction_Reference(esop : ESOP, controls : Qubit[], target : Qubit) : Unit {
        let assignment = Convert.ResultArrayAsBoolArray(MultiM(controls));
        for (term in esop!) {
            ApplyIf(X, ESOPEvaluateTerm_Reference(term, assignment), target);
        }
    }
}
