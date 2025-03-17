turbo::go!({
    let is_it_lit = !shaders::get().is_empty();

    if gamepad(0).start.just_pressed() {
        audio::stop("tota");
        shaders::reset();
        let anim = animation::get("tank");
        anim.use_sprite("tank_02#walk");
    }

    // Get the pointer (aka mouse left button or touch)
    let p = pointer();

    // Check if the pointer was just pressed.
    // If so, set it to the attack animation.
    if p.just_pressed() {
        if is_it_lit {
            audio::stop("tota");
            shaders::reset();
            let anim = animation::get("tank");
            anim.use_sprite("tank_02#walk");
        } else {
            // Set the animation to attack
            let anim = animation::get("tank");
            anim.use_sprite("tank_02#attack");
            // Start tota loop if not already playing.
            if !audio::is_playing("tota") {
                audio::play("tota");
            }
            // Play one-shot audio track.
            audio::play("canon-fire");
            // Use the crazy shader called "foo"
            shaders::set("foo");
        }
    }

    // Draw the animated sprite using the animation_key.
    // By using the animation key, the sprite name and frame
    // are set from the animation with the given key.
    // The position is based on the pointer x and y position.
    sprite!(
        animation_key = "tank",
        default_sprite = if !shaders::get().is_empty() {
            "tank_02#cheer"
        } else {
            "tank_02#walk"
        },
        x = 50,
        y = 40
    );
});
