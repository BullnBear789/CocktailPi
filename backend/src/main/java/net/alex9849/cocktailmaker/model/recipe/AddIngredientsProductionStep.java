package net.alex9849.cocktailmaker.model.recipe;

import javax.persistence.DiscriminatorValue;
import java.util.List;

@DiscriminatorValue("AddIngredients")
public class AddIngredientsProductionStep implements ProductionStep {
    private List<ProductionStepIngredient> stepIngredients;

    public List<ProductionStepIngredient> getStepIngredients() {
        return stepIngredients;
    }

    public void setStepIngredients(List<ProductionStepIngredient> stepIngredients) {
        this.stepIngredients = stepIngredients;
    }
}
