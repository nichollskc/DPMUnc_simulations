library(dplyr)
library(ggplot2)

std <- function(x) sd(x)/sqrt(length(x))

#simplex_results = read.csv("simplex_results/full_results.csv") #snakemake@input[[1]])
simplex_results = read.csv(snakemake@input[[1]])
cbbPalette = c("#0072B2", "#D55E00", "#009E73", "#E69F00", "#00FFFF")

summary_df = simplex_results %>%
  filter(d == 2, inferred_K) %>%
  group_by(method, data, var_latents, noise_factor) %>%
  summarise(nruns = n(),
            ari_mean = mean(ari),
            ari_se = std(ari),
            true_k_mean = mean(true_k),
            estimated_k_mean = mean(estimated_k),
            estimated_k_se = std(estimated_k), .groups="keep") %>%
  mutate(data = recode(data, x = 'observed', z = 'latent'),
         method = recode(method, DPMUnc_novar = "DPMZeroUnc"),
         U = noise_factor,
         N = var_latents)

print(table(summary_df$nruns))
g = ggplot(summary_df, aes(colour=method, y=ari_mean, x=U)) +
  geom_line() +
  scale_colour_manual(values=cbbPalette) +
  geom_errorbar(aes(ymin=ari_mean - ari_se,
                    ymax=ari_mean + ari_se),
                width=0.2) +
  labs(y="Mean accuracy of clustering (ARI)",
       colour="Method") +
  theme(text=element_text(size=15),
        legend.position = "bottom") +
  scale_x_continuous(breaks = unique(summary_df$U)) +
  facet_grid(" N ~ data", labeller = label_both)

ggsave(snakemake@output[["ari"]], g, width=6, height=8, units="in")

# Filter to only observed data, and one set of the latent variables, which we
#   will treat as U=0.
summary_df_nolatent = summary_df %>%
  filter(data == "observed" | U == 5)
# Set U = 0 for the latent rows
summary_df_nolatent[summary_df_nolatent$data == "latent", ]$U= 0
# Add rows for DPMUnc as well as DPMZeroUnc
extra_rows = summary_df_nolatent %>%
  filter(data == "latent", method == "DPMZeroUnc") %>%
  mutate(method = "DPMUnc")
summary_df_nolatent = rbind(summary_df_nolatent, extra_rows)
g = ggplot(summary_df_nolatent, aes(colour=method, y=ari_mean, x=U)) +
  geom_line() +
  scale_colour_manual(values=cbbPalette) +
  geom_errorbar(aes(ymin=ari_mean - ari_se,
                    ymax=ari_mean + ari_se),
                width=0.2) +
  labs(y="Mean accuracy of clustering (ARI)",
       colour="Method") +
  theme(text=element_text(size=15),
        legend.position = "bottom") +
  scale_x_continuous(breaks = unique(summary_df_nolatent$U)) +
  facet_grid(" N ~ .", labeller = label_both)

ggsave(snakemake@output[["ari_nolatent"]], g, width=6, height=8, units="in")

g = ggplot(summary_df, aes(colour=method, y=estimated_k_mean, x=U)) +
  geom_line() +
  scale_colour_manual(values=cbbPalette) +
  labs(y="Estimated K",
       colour="Method") +
  theme(text=element_text(size=15),
        legend.position = "bottom") +
  scale_x_continuous(breaks = unique(summary_df$U)) +
  facet_grid(" N ~ data", labeller = label_both)

ggsave(snakemake@output[["K_line"]], g, width=6, height=8, units="in")

tidied_results = simplex_results %>%
  filter(d == 2, inferred_K, data == "x") %>%
  mutate(data = recode(data, x = 'observed', z = 'latent'),
         method = recode(method, DPMUnc_novar = "DPMZeroUnc"),
         U = noise_factor,
         N = var_latents)

g = ggplot(tidied_results, aes(fill=method, x=estimated_k)) +
  geom_histogram() +
  scale_fill_manual(values=cbbPalette) +
  scale_x_continuous(breaks = 1:8) +
  labs(x="Estimated K") +
  theme(text=element_text(size=15),
        legend.position = "bottom") +
  facet_grid("N ~ method", labeller = label_both)

ggsave(snakemake@output[["K_hist"]], g, width=10, height=8, units="in")
