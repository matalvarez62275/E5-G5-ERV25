# E5-G5-ERV25
Assignment for Electrónica V (22.15) - ERV25 processor
Instituto Tecnológico de Buenos Aires

The project involves designing, simulating, and testing a custom RISC-V processor that adheres to the fundamental specifications of the RISC-V instruction set architecture (ISA). It serves as a practical application of theoretical knowledge, integrating concepts like instruction decoding, pipeline processing, and memory management.

## Keeping the main ERV25.bdf file from `develop` 

When pulling changes from the `develop` branch into your feature branch, follow these steps to always keep the version of the ERV25.bdf file from `develop`:

1. **Pull the `develop` branch into your feature branch**:
   ```bash
   git pull origin develop

2. **Discard your changes to the file and reset it to the version from `develop`**:
   ```bash
   git checkout --theirs src/ERV25.bdf
   
4. **Add the resolved file to the staging area**:
   ```bash
   git add src/ERV25.bdf
   
6. **Complete the merge process**:
   ```bash
   git commit
