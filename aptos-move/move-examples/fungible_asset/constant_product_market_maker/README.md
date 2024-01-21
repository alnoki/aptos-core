## Price impact calculations

For base $b$ and quote $q$, price $p = \frac{q}{b}$.

For initial price $p_0$ and final price $p_f$, price impact in basis points $i$:

$$i = 10,000 \frac{\lvert p_0 - p_f \rvert}{p_0}$$

$$i = 10,000 \frac{\lvert \frac{q_0}{b_0} - \frac{q_f}{b_f}\rvert}{\frac{q_0}{b_0}}$$

$$i = 10,000 \frac{b_0 b_f \lvert \frac{q_0}{b_0} - \frac{q_f}{b_f}\rvert}{b_0 b_f \frac{q_0}{b_0}}$$

$$i = 10,000 \frac{\lvert b_f q_0 - b_0 q_f\rvert}{b_f q_0}$$

Let $a = b_f q_0$, $b = b_0 q_f$:

$$i = 10,000 \frac{\lvert a - b \rvert}{a}$$

$$i = 10,000 \frac{max(a, b) - min(a, b)}{a}$$