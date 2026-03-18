return {

    ---------------------------------------------------------------------------
    -- Base templates (kept for backward compatibility with user overrides)
    ---------------------------------------------------------------------------

    xp_t1_base = {
        template = true,
        offer = {
            weight = 1.0
        }
    },
    xp_t2_base = {
        template = true,
        offer = {
            weight = 1.0
        }
    },
    xp_t3_base = {
        template = true,
        offer = {
            weight = 0.8
        }
    },
    boost_base_xp = {
        template = true,
        offer = {
            weight = 0.4,
            stock = {
                min = 1,
                max = 1,
                restockHours = 48
            }
        }
    },
}
