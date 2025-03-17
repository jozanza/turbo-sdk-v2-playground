turbo::go!({
    // If there's a custom shader set, we think it's party time!
    let is_it_lit = !shaders::get().is_empty();

    // Get the pointer (aka mouse left button or touch)
    let p = pointer();

    // Check if the pointer was just pressed.
    // If so, set it to the attack animation.
    if p.just_pressed() {
        if is_it_lit {
            // Set the animation back to walk.
            let anim = animation::get("tank");
            anim.use_sprite("tank_02#walk");
            // Stop the tota audio loop.
            audio::stop("tota");
            shaders::reset();
        } else {
            // Set the animation to attack.
            let anim = animation::get("tank");
            anim.use_sprite("tank_02#attack");
            // Start tota audio loop if not already playing.
            if !audio::is_playing("tota") {
                audio::play("tota");
            }
            // Play one-shot audio track.
            audio::play("canon-fire");
            // Use the crazy shader called "foo"
            shaders::set("foo");
        }
    }

    // Let's make it extra jazzy by displaying text with a custom font.
    if is_it_lit {
        text!("IT'S LIT!!!", font = "OldWizard", x = 20, y = 40);
    }

    // Draw the animated sprite using the animation_key.
    // By using the animation key, the sprite name and frame
    // are set from the animation with the given key.
    // The position is based on the pointer x and y position.
    sprite!(
        animation_key = "tank",
        // When an animation completes its loop count,
        // The animation will use the default set here.
        default_sprite = if is_it_lit {
            "tank_02#cheer"
        } else {
            "tank_02#walk"
        },
        x = 50,
        y = 50
    );
});
