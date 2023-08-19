package net.alex9849.cocktailmaker.payload.response;

import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class GlobalSettings {
    private boolean allowReversePumping;
    private Donation donation;

    @Getter @Setter
    public static class Donation {
        private boolean donated;
        private boolean showDisclaimer;
        private Integer disclaimerDelay;
    }
}
