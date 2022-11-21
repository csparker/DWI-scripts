# Authors: Carlos Estevez Fraga (c.fraga _at_ ucl.ac.uk) & Christopher Parker (christopher.parker _at_ ucl.ac.uk)

#!/bin/bash

# REGISTER DWI IMAGES IN MNI SPACE WITH NIFTYREG
#INPUT: T1, DWI (eg MD maps)

for j in `awk '{print $1}' all.txt` ; do

echo ${j}

# Brain extraction

bet T1_${j}.nii.gz T1_brain_${j}.nii.gz -m -B

# Align the T1 to the MNI_152_2mm_brain image using an affine transform
# Output = ${j}_T1_MNI_Affine.txt & ${j}_T1_MNI_Affine.nii.gz

reg_aladin -flo T1_brain_${j}.nii.gz -ref /midas-data/software/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz -res ${j}_T1_MNI_Affine.nii.gz -aff ${j}_T1_MNI_Affine.txt

# Now use a nonlinear transform (fnirt) to warp the T1 to the MNI space
# Output ${j}_T1_MNI_Nonli.nii (field map) & ${j}_T1_MNI_Affine_Nonli.nii.gz
reg_f3d  -ref /midas-data/software/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz  -flo T1_brain_${j}.nii.gz -aff ${j}_T1_MNI_Affine.txt -cpp ${j}_T1_MNI_Nonli -res ${j}_T1_MNI_Affine_Nonli.nii.gz


# Now flirt the DWI image to the anatomical image using boundary based registration (BBR)
#First (output is ${j}_DWI_to_T1_dti_FA_lin)
reg_aladin -ref T1_brain_${j}.nii.gz -flo HD1_dti_FA_${j}.nii.gz -res ${j}_DWI_to_T1_dti_FA_lin -aff ${j}_DWI_to_T1_dti_FA_Affine.txt

#Second (output is ${j}_DWI_to_T1_dti_FA_Affine_Nonli.nii.gz )
reg_f3d -ref T1_brain_${j}.nii.gz -flo HD1_dti_FA_${j}.nii.gz -aff ${j}_DWI_to_T1_dti_FA_Affine.txt -cpp ${j}_DWI_to_T1_dti_FA_Nonli -res ${j}_DWI_to_T1_dti_FA_Affine_Nonli.nii.gz

# Now concatenate the transforms
reg_transform -ref /midas-data/software/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz -comp1 ${j}_DWI_to_T1_dti_FA_Nonli.nii.gz ${j}_T1_MNI_Nonli.nii.gz ${j}_DWI_MNI_Nonli_TRANS


#Apply the transforms (output is  ${j}_DWI_MNI_final )

reg_resample -ref /midas-data/software/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz -flo HD1_dti_FA_${j}.nii.gz -def ${j}_DWI_MNI_Nonli_TRANS -res  ${j}_DWI_MNI_final

done
