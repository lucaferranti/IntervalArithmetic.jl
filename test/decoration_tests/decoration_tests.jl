using IntervalArithmetic
using Test

let b

@testset "DecoratedInterval tests" begin
    a = DecoratedInterval(@interval(1, 2), com)
    @test decoration(a) == com

    b = sqrt(a)
    @test interval(b) == sqrt(interval(a))
    @test decoration(b) == com

    a = DecoratedInterval(@interval(-1, 1), com)
    b = sqrt(a)
    @test interval(b) == sqrt(Interval(0, 1))
    @test decoration(b) == trv

    d = DecoratedInterval(a, dac)
    @test decoration(d) == dac

    @test decoration(DecoratedInterval(1.1)) == com
    @test decoration(DecoratedInterval(1.1, dac)) == dac

    @test decoration(DecoratedInterval(2, 0.1, com)) == ill
    @test decoration(DecoratedInterval(2, 0.1)) == ill
    @test isnai(DecoratedInterval(2, 0.1))
    @test decoration(@decorated(2, 0.1)) == ill
    @test decoration(DecoratedInterval(big(2), big(1))) == ill
    @test isnai((DecoratedInterval(big(2), big(1))))
    @test isnai(@decorated(big(2), big(1)))

    # Disabling the following tests, because Julia 0.5 has some strange behaviour here
    # @test_throws ArgumentError DecoratedInterval(BigInt(1), 1//10)
    # @test_throws ArgumentError @decorated(BigInt(1), 1//10)

    # Tests related to powers of decorated Intervals
    @test @decorated(2,3) ^ 2 == DecoratedInterval(4, 9)
    @test @decorated(2,3) ^ -2 == DecoratedInterval(1/9,1/4)
    @test @decorated(-3,2) ^ 3 == DecoratedInterval(-27., 8.)
    @test @decorated(-3,-2) ^ -3 == DecoratedInterval(-1/8.,-1/27)
    @test @decorated(0,3) ^ 2 == DecoratedInterval(0, 9)
    @test @decorated(0,3) ^ -2 == DecoratedInterval(1/9, Inf, trv)
    @test @decorated(2,3)^@decorated(0.0, 1.0) == DecoratedInterval(1.0,3.0)
    @test @decorated(0, 2)^@decorated(0.0, 1.0) == DecoratedInterval(0.0,2.0, trv)
    @test @decorated(-3, 2)^@decorated(0.0, 1.0) == DecoratedInterval(0.0,2.0, trv)
    @test @decorated(-3, 2)^@decorated(-1.0, 1.0) == DecoratedInterval(0.0,Inf, trv)

    a = @decorated 1 2
    b = @decorated 3 4

    @test dist(a, b) == 2.0
end

@testset "Convert string to DecoratedInterval" begin
    @test convert(DecoratedInterval{Float64}, "[1,2]") ==
                    DecoratedInterval(Interval(1, 2), com)

    @test convert(DecoratedInterval{Float64}, "[1,2]_dac") ==
                        DecoratedInterval(Interval(1, 2), dac)

end


@testset "Decorated intervals comparison" begin

    a = @decorated 1 3

    b = @decorated 4 5

    @test a != b

    @test a < b
    @test b > a
    @test a <= b
    @test b >= a

end

@testset "Mixed bare/decorated operations" begin

    a = 1..2
    b = @decorated 3 4
    for op in (:(==), :!=, :<=, :>=, :<, :>, :≼, :≺, :⊂, :⊃, :⊇, :⊆, :⪽, :isdisjoint,
        :+, :-, :*, :/, ://, :^, :pow, :extended_div, :atan, :min, :max, :dist,
        :cancelminus, :cancelplus, :hypot, :copysign, :flipsign,
        :in, :intersect, :union, :setdiff, :hull)

        @eval @test_throws ArgumentError $op($a, $b)
        @eval @test_throws ArgumentError $op($b, $a)
    end

    @test_throws ArgumentError fma(a, a, b)
    @test_throws ArgumentError fma(a, b, a)
    @test_throws ArgumentError fma(b, a, a)
    @test_throws ArgumentError fma(a, b, b)
    @test_throws ArgumentError fma(b, b, a)
    @test_throws ArgumentError fma(b, a, b)
end
end
