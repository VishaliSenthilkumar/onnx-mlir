// RUN: onnx-mlir --march=z16 --maccel=NNPA --EmitZHighIR --nnpa-disable-saturation --printIR %s | FileCheck --check-prefix=ZHIGH_OFF %s
// RUN: onnx-mlir --march=z16 --maccel=NNPA --EmitZHighIR --printIR %s | FileCheck --check-prefix=ZHIGH_ON %s
// RUN: onnx-mlir --march=z16 --maccel=NNPA --EmitZLowIR --nnpa-disable-saturation --printIR %s | FileCheck --check-prefix=ZLOW_OFF %s
// RUN: onnx-mlir --march=z16 --maccel=NNPA --EmitZLowIR --printIR %s | FileCheck --check-prefix=ZLOW_ON %s
// RUN: onnx-mlir-opt --march=z16 --maccel=NNPA --nnpa-disable-saturation --shape-inference --convert-onnx-to-zhigh --zhigh-decompose-stick-unstick %s | FileCheck --check-prefix=DECOMPOSE_OFF %s
// RUN: onnx-mlir-opt --march=z16 --maccel=NNPA --shape-inference --convert-onnx-to-zhigh --zhigh-decompose-stick-unstick %s | FileCheck --check-prefix=DECOMPOSE_ON %s
// RUN: onnx-mlir --march=z16 --maccel=NNPA --EmitMLIR --nnpa-disable-saturation --printIR %s | FileCheck --check-prefix=COMPILER_STICK_OFF %s
// RUN: onnx-mlir --march=z16 --maccel=NNPA --EmitMLIR --printIR %s | FileCheck --check-prefix=COMPILER_STICK_ON %s

// COM: for each case, check saturation ON and OFF.

func.func @saturation(%arg0 : tensor<10x10xf32>) -> tensor<*xf32> {
  %0 = "onnx.Relu"(%arg0) : (tensor<10x10xf32>) -> tensor<*xf32>
  "func.return"(%0) : (tensor<*xf32>) -> ()
// ZHIGH_ON-LABEL: func @saturation
// ZHIGH_ON: "zhigh.Stick"({{.*}}) {layout = "2D"} : {{.*}} 

// ZHIGH_OFF-LABEL: func @saturation
// ZHIGH_OFF: "zhigh.Stick"({{.*}}) {layout = "2D", no_saturation = -1 : si64} : {{.*}} 


// ZLOW_ON-LABEL: func @saturation
// ZLOW_ON:   "zlow.stick"({{.*}}, {{.*}}) {layout = "2D"} : {{.*}} 

// ZLOW_OFF-LABEL: func @saturation
// ZLOW_OFF:   "zlow.stick"({{.*}}, {{.*}}) {layout = "2D", no_saturation = -1 : si64} : {{.*}} 

// DECOMPOSE_ON-LABEL: func @saturation
// DECOMPOSE_ON: "zhigh.F32ToDLF16"(%arg0) :  {{.*}}

// DECOMPOSE_OFF-LABEL: func @saturation
// DECOMPOSE_OFF: "zhigh.F32ToDLF16"(%arg0) {no_saturation = -1 : si64} :  {{.*}}

// COMPILER_STICK_OFF-LABEL: func @saturation
// COMPILER_STICK_OFF-NOT: arith.minnumf 
// COMPILER_STICK_OFF-NOT: arith.maxnumf 
// COMPILER_STICK_OFF: zlow.relu 

// COMPILER_STICK_ON-LABEL: func @saturation
// COMPILER_STICK_ON: arith.minnumf 
// COMPILER_STICK_ON: arith.maxnumf 
// COMPILER_STICK_ON: zlow.relu 
}

