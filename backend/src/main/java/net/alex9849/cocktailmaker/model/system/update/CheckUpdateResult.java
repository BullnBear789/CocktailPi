package net.alex9849.cocktailmaker.model.system.update;

import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class CheckUpdateResult {
    private boolean updateAvailable;
    private String currentVersion;
    private String newestVersion;
}
