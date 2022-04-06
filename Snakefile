localrules: test

wildcard_constraints:
    seed="\d+",
    n="\d+",
    d="\d+",
    k="\d+",

rule test:
    input:
        expand("results/{n}_{d}_{k}_{var_latents}_{var_means}_{noise_factor}_{seed}/results.csv",
               seed=range(20),
               n=50,
               d=4,
               k=[2, 4, 8],
               var_latents=["1e-1", "5e-1", 1, 2, 3],
               var_means=[1, 2, 4, 6, 9],
               noise_factor=["1e-1", "5e-1", 1, 2, 4])

rule basic_simulation:
    output:
        clusterAllocations="results/{n}_{d}_{k}_{var_latents}_{var_means}_{noise_factor}_{seed}/{seed}/simple/clusterAllocations.csv",
        clusterAllocationsNovar="results/{n}_{d}_{k}_{var_latents}_{var_means}_{noise_factor}_{seed}/{seed}/novar/clusterAllocations.csv",
        clusterAllocationsLatents="results/{n}_{d}_{k}_{var_latents}_{var_means}_{noise_factor}_{seed}/{seed}/latents/clusterAllocations.csv",
        summary="results/{n}_{d}_{k}_{var_latents}_{var_means}_{noise_factor}_{seed}/results.csv",
        rda="results/{n}_{d}_{k}_{var_latents}_{var_means}_{noise_factor}_{seed}/results.rda",
    script:
        "scripts/basic_snakemake.R"

#snakemake --snakefile DPMUnc.rules -k -j 1000 --cluster-config cluster.json --cluster "sbatch -A {cluster.account} -p {cluster.partition}  -c {cluster.cpus-per-task} -t {cluster.time} ut {cluster.error} -J {cluster.job} "
