rm(list = ls())
library(smoothHP)

if(!dir.exists("data")){
    dir.create("data")
}

anchor_year <- 2015
years_out <- 30
gq_tracts <- "53033005302"

# make projections for non gq locations
proj_nongq_df <- multi_stage_group_HP_project(
    kc_pop_data[!(GEOID %in% gq_tracts),],
    stages = list("County", "Race", "GEOID"),
    par_year = anchor_year, proj_year = anchor_year, years_out = years_out)

# make projections for gq locations
proj_gq_df <- bind_rows(lapply(gq_tracts, function(t){
    sub_df <- kc_pop_data[GEOID == t & Year == anchor_year,]
    new_years <- seq(anchor_year + 5, anchor_year + years_out, 5)

    bind_rows(lapply(new_years, function(y){
        sub_df %>%
            mutate(Year = y)
    }))
}))

# combine and save
proj_nongq_df %>%
    bind_rows(proj_gq_df) %>%
    select(-County) %>%
    arrange(Year, GEOID, Sex, Race, Age5) %>%
    fwrite("data/phi_projections.csv")
