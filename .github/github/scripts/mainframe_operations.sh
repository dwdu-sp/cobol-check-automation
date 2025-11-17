#!/bin/bash
# mainframe_operations.sh

# Set up environment
export PATH=$PATH:/usr/lpp/java/J8.0_64/bin
export JAVA_HOME=/usr/lpp/java/J8.0_64
export PATH=$PATH:/usr/lpp/zowe/cli/node/bin

# Check Java availability
java -version

# Change to the cobolcheck directory
cd cobolcheck
echo "Changed to $(pwd)"
ls -al

# Make cobolcheck executable
chmod +x cobolcheck
echo "Made cobolcheck executable"

# Make script in scripts directory executable (assuming 'linux_gnucobol_run_tests' exists)
# Note: This part might be specific to certain setups. If 'scripts' directory or this file doesn't exist,
# this step might not be strictly necessary or might need adjustment based on your COBOL Check setup.
# For now, we'll include it as per the course material.
if [ -d "scripts" ]; then
  cd scripts
  if [ -f "linux_gnucobol_run_tests" ]; then
    chmod +x linux_gnucobol_run_tests
    echo "Made linux_gnucobol_run_tests executable"
  else
    echo "Warning: linux_gnucobol_run_tests not found in scripts directory."
  fi
  cd ..
else
  echo "Warning: 'scripts' directory not found inside cobolcheck."
fi

# Function to run cobolcheck and copy files
run_cobolcheck() {
  program=$1
  echo "Running cobolcheck for $program"
  # Run cobolcheck, but don't exit if it fails
  ./cobolcheck -p "$program"
  echo "Cobolcheck execution completed for $program (exceptions may have occurred)"

  # Check if CC##99.CBL was created, regardless of cobolcheck exit status
  if [ -f "CC##99.CBL" ]; then
    # Copy to the MVS dataset
    # Using ZOWE_USERNAME directly from environment, which comes from GitHub Secrets
    if cp CC##99.CBL "//'${ZOWE_USERNAME}.CBL($program)'"; then
      echo "Copied CC##99.CBL to ${ZOWE_USERNAME}.CBL($program)"
    else
      echo "Failed to copy CC##99.CBL to ${ZOWE_USERNAME}.CBL($program)"
    fi
  else
    echo "CC##99.CBL not found for $program"
  fi

  # Copy the JCL file if it exists
  if [ -f "${program}.JCL" ]; then
    if cp "${program}.JCL" "//'${ZOWE_USERNAME}.JCL($program)'"; then
      echo "Copied ${program}.JCL to ${ZOWE_USERNAME}.JCL($program)"
    else
      echo "Failed to copy ${program}.JCL to ${ZOWE_USERNAME}.JCL($program)"
    fi
  else
    echo "${program}.JCL not found"
  fi
}

# Run for each program
for program in NUMBERS EMPPAY DEPTPAY; do
  run_cobolcheck "$program"
done

echo "Mainframe operations completed"
