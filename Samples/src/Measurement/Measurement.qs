// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.Measurement {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Measurement;

    //////////////////////////////////////////////////////////////////////////
    // Introduction //////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    // This sample shows the use of measurement operations, how to use assertions
    // to build tests for expected behaviour of operations that involve measurements
    // and gives examples for operations that require resetting of allocated qubits.

    // In Q# the primitive measurement operation is called M which is a single qubit
    // measurement in the standard basis (i.e., the eigenbasis of the Pauli-Z operator)
    // and which has type signature M: Qubit -> Result, where Qubit is a single Qubit
    // and Result is the type reserved for results, i.e., a discriminated union type
    // that either takes value Zero or value One.

    // Measurements in other Pauli bases besides Pauli-Z are possible, and also joint
    // measurements of a general Pauli operator on n qubits is possible. This for a
    // given Pauli operator $P$ the corresponding measurement is an outcome observable
    // with projectors $\frac{1}{2}(1+P)$ and $\frac{1}{2}(1-P)$ corresponding to the
    // +1 and -1 eigenspaces of $P$.

    // As far as assertions are concerned, in this sample we use Assert and AssertProb
    // to assert either that a given qubit is in an expected state (with certainty) or
    // that upon measurement, we would obtain a certain result with a given probability,
    // where also a target accuracy is provided which is necessary as the targeted
    // machine may implement measurements by a sampling procedure.

    /// # Summary
    /// Measurement example: create a state $1/\sqrt(2)(|0\rangle+|1\rangle)$ and
    /// measure it in the Pauli-Z basis.
    ///
    /// # Remarks
    /// It is asserted that upon measurement in the Pauli-Z basis a perfect coin toss
    /// of a 50-50 coin results.
    operation MeasureOneQubit() : Result {
        // The following using block creates a fresh qubit and initializes it in |0〉.
        using (qubit = Qubit()) {

            // Apply a Hadamard operation H to the state, thereby creating
            // the state 1/sqrt(2)(|0〉+|1〉).
            H(qubit);
            AssertProb([PauliZ], [qubit], Zero, 0.5, "Error: Outcomes of the measurement must be equally likely", 1E-05);

            // Now we measure the qubit in Z-basis
            let result = M(qubit);

            // As the qubit is now in an eigenstate of the measurement operator,
            // i.e., either in |0⟩ or in |1⟩, and qubits need to be in |0⟩ when they
            // are released, we have to manually reset the qubit before releasing it.
            // Note that this is how the Microsoft.Quantum.Measurement.MResetZ
            // operation works.
            if (result == One) {
                X(qubit);
            }

            // Finally, we return the result of the measurement.
            return result;
        }
    }

    /// # Summary
    /// Measurement example: create a state $1/2(|00\rangle+|01\rangle+|10\rangle+|11\rangle)$
    /// and measure both qubits in the Pauli-Z basis.
    ///
    /// # Remarks
    /// It is asserted that upon measurement in the Pauli-Z basis a perfect coin toss of two
    /// 50-50 coins results.
    operation MeasureTwoQubits() : (Result, Result) {
        // The following using block creates a pair of fresh qubits and initializes it in |00〉.
        using ((left, right) = (Qubit(), Qubit())) {
            // By applying the Hadamard operator to each of the two qubits we create state
            // 1/2(|00〉+|01〉+|10〉+|11〉).
            ApplyToEach(H, [left, right]);

            // We now assert that the probability for the events of finding the first qubit
            // in state |0〉 upon measurement in the standard basis is $1/2$. Note that this
            // assertion does not actually apply the measurement operation itself, i.e., it
            // has no side effect on the state of the qubits.
            AssertProb([PauliZ], [left], Zero, 0.5, "Error: Outcomes of the measurement must be equally likely", 1E-05);

            // We now assert that the probability for the events of finding the second
            // qubit in state |0〉 upon measurement in the standard basis is $1/2$.
            AssertProb([PauliZ], [right], Zero, 0.5, "Error: Outcomes of the measurement must be equally likely", 1E-05);

            // Now, we measure each qubit in Z-basis and immediately reset the qubits
            // to zero, using the canon operation MResetZ.
            return (MResetZ(left), MResetZ(right));
        }
    }

    /// # Summary
    /// Measurement example: create a state $1/\sqrt(2)(|00\rangle+|11\rangle)$ and measure
    /// it in the Pauli-Z basis.
    ///
    /// # Remarks
    /// It is asserted that upon measurement in the Pauli-Z basis a perfect coin toss of a
    /// 50-50 coin results with outcomes "00" and "11".
    operation MeasureInBellBasis() : (Result, Result) {
        // The following using block creates a fresh qubit and initializes it in |0〉.
        using ((left, right) = (Qubit(), Qubit())) {
            // By applying the Hadamard operator and a CNOT, we create the cat state
            // 1/sqrt(2)(|00〉+|11〉).
            H(left);
            CNOT(left, right);

            // The following two assertions ascertain that the created state is indeed
            // invariant under both, the XX and the ZZ operations, i.e., it projects
            // into the +1 eigenstate of these two Pauli operators.
            Assert([PauliZ, PauliZ], [left, right], Zero, "Error: EPR state must be eigenstate of ZZ");
            Assert([PauliX, PauliX], [left, right], Zero, "Error: EPR state must be eigenstate of XX");
            AssertProb([PauliZ, PauliZ], [left, right], One, 0.0, "Error: 01 or 10 should never occur as an outcome", 1E-05);

            // Finally, we measure each qubit in Z-basis and construct a tuple from the results.
            return (MResetZ(left), MResetZ(right));
        }
    }

}


